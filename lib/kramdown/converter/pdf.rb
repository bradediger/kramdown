# -*- coding: utf-8 -*-
#
#--
# Copyright (C) 2009-2010 Thomas Leitner <t_leitner@gmx.at>
#
# This file is part of kramdown.
#
# kramdown is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
#

require 'rubygems'
gem 'prawn', '0.11.1'

require 'rexml/parsers/baseparser'
require 'prawn'

module Kramdown

  module Converter

    class Pdf < Base

      begin
        require 'coderay'

        # Highlighting via coderay is available if this constant is +true+.
        HIGHLIGHTING_AVAILABLE = true
      rescue LoadError => e
        HIGHLIGHTING_AVAILABLE = false  # :nodoc:
      end

      include ::Kramdown::Utils::Html


      # The amount of indentation used when nesting HTML tags.
      attr_accessor :indent

      attr_reader :pdf

      # Initialize the HTML converter with the given Kramdown document +doc+.
      def initialize(root, options)
        super
        @footnote_counter = @footnote_start = @options[:footnote_nr]
        @footnotes = []
        @toc = []
        @toc_code = nil
        @indent = 2
        @stack = []
        @pdf = Prawn::Document.new
      end

      # The mapping of element type to conversion method.
      DISPATCHER = Hash.new {|h,k| h[k] = "convert_#{k}"}

      # Dispatch the conversion of the element +el+ to a <tt>convert_TYPE</tt> method using the
      # +type+ of the element.
      def convert(el, indent = -@indent)
        send(DISPATCHER[el.type], el, indent)
        @pdf.render
      end

      # Return the converted content of the children of +el+ as a string. The parameter +indent+ has
      # to be the amount of indentation used for the element +el+.
      #
      # Pushes +el+ onto the <tt>@stack</tt> before converting the child elements and pops it from
      # the stack afterwards.
      def inner(el, indent)
        result = ''
        indent += @indent
        @stack.push(el)
        el.children.each do |inner_el|
          result << send(DISPATCHER[inner_el.type], inner_el, indent)
        end
        @stack.pop
        result
      end

      def convert_blank(el, indent)
        ""
      end

      def convert_text(el, indent)
        el.value
      end

      def convert_p(el, indent)
        inner(el, indent)
      end

      def convert_codeblock(el, indent)
        inner(el, indent)
      end

      def convert_blockquote(el, indent)
        inner(el, indent)
      end

      def convert_header(el, indent)
        inner(el, indent)
      end

      def convert_hr(el, indent)
        inner(el, indent)
      end

      def convert_ul(el, indent)
        inner(el, indent)
      end
      alias :convert_ol :convert_ul
      alias :convert_dl :convert_ul

      def convert_li(el, indent)
        @pdf.text "* #{inner(el, indent)}"
        ""
      end
      alias :convert_dd :convert_li

      def convert_dt(el, indent)
        inner(el, indent)
      end

      def convert_html_element(el, indent)
        inner(el, indent)
      end

      def convert_xml_comment(el, indent)
      end
      alias :convert_xml_pi :convert_xml_comment

      def convert_table(el, indent)
      end

      def convert_thead(el, indent)
      end
      alias :convert_tbody :convert_thead
      alias :convert_tfoot :convert_thead
      alias :convert_tr  :convert_thead

      def convert_td(el, indent)
      end

      def convert_comment(el, indent)
      end

      def convert_br(el, indent)
      end

      def convert_a(el, indent)
      end

      def convert_img(el, indent)
      end

      def convert_codespan(el, indent)
      end

      def convert_footnote(el, indent)
      end

      def convert_raw(el, indent)
      end

      def convert_em(el, indent)
      end
      alias :convert_strong :convert_em

      def convert_entity(el, indent)
      end

      def convert_typographic_sym(el, indent)
      end

      def convert_smart_quote(el, indent)
      end

      def convert_math(el, indent)
      end

      def convert_abbreviation(el, indent)
      end

      def convert_root(el, indent)
        inner(el, indent)
      end

    end

  end
end
