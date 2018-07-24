Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388421AbeGXIjY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:24 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 13/24] pynfs: python3 support plan: list.sort() -> newlist = sorted(list)
Date: Tue, 24 Jul 2018 15:33:31 +0800
Message-Id: <20180724073342.5738-13-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 xdr/xdrgen.py | 56 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 35 insertions(+), 21 deletions(-)

diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index bed2181..6303184 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -305,7 +305,7 @@ def t_linecomment(t):
 def t_error(t):
     print("Illegal character %s at %d type %s" % (repr(t.value[0]), t.lexer.lineno, t.type))
     t.lexer.skip(1)
-    
+
 # Build the lexer
 lex.lex(debug=0)
 
@@ -641,7 +641,7 @@ def p_proc_firstarg(t):
 def p_type_specifier_list(t):
     '''type_specifier_list : COMMA type_specifier type_specifier_list
                            | empty'''
-    
+
 
 ##########################################################################
 #                                                                        #
@@ -718,7 +718,7 @@ class Info(object):
 
     def const_output(self):
         return None
-    
+
     def type_output(self):
         return None
 
@@ -853,7 +853,7 @@ class Info(object):
         else:
             subheader = array = varindent = ''
         return prefix+varindent, newdata, subheader, array
-        
+
     def packenum(self, prefix, data='data'):
         prefix, data, subheader, array = self._array_pack(prefix, data)
         varlist = ["const.%s" % l.id for l in self.body]
@@ -952,7 +952,7 @@ class Info(object):
         else:
             unpack += "%s%sraise XDRError('bad switch=%%s' %% %s.%s)\n" % \
                       (prefix, indent, data, switch.id)
-            
+
         return subheader + unpack + array
 
     def xdrbody(self, prefix=''):
@@ -977,7 +977,7 @@ class Info(object):
                         ''.join(["%s\n" % d.xdrout(prefix + indent)
                                  for d in self.body[-1].declarations])
         return body
-            
+
 class const_info(Info):
     """The result of 'CONST ID EQUALS constant SEMI' or inside of enum as
     'ID EQUALS value' """
@@ -988,13 +988,16 @@ class const_info(Info):
         self.lineno = self.sortno = lineno
         self.type = 'const'
         self.enum = enum
-        
+
     def __repr__(self):
         return "constant %s=%s at line %s" % (self.id, self.value, self.lineno)
 
+    def __lt__(self, other):
+        return self.sortno < other.sortno
+
     def xdrout(self, prefix=''):
         return "%s%s = %s" % (prefix, self.id, self.value)
-    
+
     def const_output(self):
         return "%s = %s\n" % (self.id, self.value)
 
@@ -1016,6 +1019,9 @@ class enum_info(Info):
         self.array = False
         self.parent = True
 
+    def __lt__(self, other):
+        return self.sortno < other.sortno
+
     def const_output(self):
         body = ''.join(["%s%s : '%s',\n" % (indent, l.value, l.id)
                         for l in self.body])
@@ -1029,7 +1035,7 @@ class enum_info(Info):
         header = "%sdef unpack_%s(self):\n" % (indent, self.id)
         return header + self.unpackenum(indent2) + \
                self._get_unpack_footer()
-        
+
 class struct_info(Info):
     """The result of 'TYPEDEF STRUCT <struct_body> ID <array> SEMI' or
     'STRUCT ID <struct_body> SEMI'
@@ -1048,6 +1054,9 @@ class struct_info(Info):
         self.array = False
         self.parent = True
 
+    def __lt__(self, other):
+        return self.sortno < other.sortno
+
     def type_output(self):
         comment = '%s# ' % indent
         xdrbody = self.xdrbody(comment)
@@ -1079,11 +1088,11 @@ class struct_info(Info):
                    (indent, indent2, candidates[0].id)
         else:
             return ''
-        
+
     def pack_output(self):
         header = self._get_pack_header()
         return header + self.packstruct(indent2)
-        
+
     def unpack_output(self):
         header = "%sdef unpack_%s(self):\n" % (indent, self.id)
         return header + self.unpackstruct(indent2) + \
@@ -1107,6 +1116,9 @@ class union_info(Info):
         self.array = False
         self.parent = True
 
+    def __lt__(self, other):
+        return self.sortno < other.sortno
+
     def union_getattr(self, prefix=indent):
         return "%sdef __getattr__(self, attr):\n"\
                "%s%sreturn getattr(self.switch, attr)\n" % \
@@ -1174,6 +1186,9 @@ class type_info(Info):
             self.fixed = False
         self.parent = False
 
+    def __lt__(self, other):
+        return self.sortno < other.sortno
+
     def __str__(self):
         return "%s %s at line %s" % (self.type, self.id, self.lineno)
 
@@ -1198,14 +1213,14 @@ class type_info(Info):
             x.len = self.len
             x.fixed = self.fixed
         return x
-        
+
     def xdrout(self, prefix=''):
         if self.type == 'void':
             return "%svoid;" % prefix
         elif self.type == 'enum':
             body = self.xdrbody(prefix)
             name = "%senum {\n%s%s}" % (prefix, body, prefix)
-            
+
         elif self.type == 'struct':
             body = self.xdrbody(prefix)
             name = "%sstruct {\n%s%s}" % (prefix, body, prefix)
@@ -1260,7 +1275,7 @@ class type_info(Info):
                     return "%s = %s\n" % (self.id, self.type)
                 elif cast.type == "enum":
                     return "%s = const.%s\n" % (self.id, self.type)
-        
+
     def pack_output(self):
         if not self.array:
             return "%spack_%s = pack_%s\n" % (indent, self.id, self.type)
@@ -1297,7 +1312,7 @@ class type_info(Info):
         pack = "%sself.pack_%s%s(%s%s%s)\n" % \
                (prefix, fixchar, type, fixnum, data, packer)
         return limit + pack
-        
+
     def _unpack_array(self, prefix, data='data'):
         if self.fixed or self.len is None:
             limit = ''
@@ -1322,9 +1337,9 @@ class type_info(Info):
         pack = "%s%s = self.unpack_%s%s(%s)\n" % \
                (prefix, data, fixchar, type, ', '.join(fixnum+packer))
         return pack + limit
-        
-     
-        
+
+
+
 ##########################################################################
 #                                                                        #
 #                          Main Loop                                     #
@@ -1430,8 +1445,7 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
     pack_fd.write(pack_init % name_base.upper())
     pack_fd.write(packer_start)
 
-    type_list = name_dict.values()
-    type_list.sort()
+    type_list = sorted(name_dict.values())
     for value in type_list:
         #print(value)
         output = value.const_output()
@@ -1454,7 +1468,7 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
         if output is not None:
             pack_fd.write(output)
             pack_fd.write('\n')
-            
+
     const_fd.close()
     type_fd.close()
     pack_fd.close()
-- 
2.17.1

