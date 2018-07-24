Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388346AbeGXIjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:06 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 04/24] pynfs: python3 support plan: "raise E, args:" -> "raise E(args)"
Date: Tue, 24 Jul 2018 15:33:22 +0800
Message-Id: <20180724073342.5738-4-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

'/raise / { :loop /[^\\]$/! {N; b loop};
  s/\<raise  *([[:alnum:]]+), *(.+)$/raise \1(\2)/;
  s/%sraise  *([[:alnum:]]+), *([^"]+)\\n"/%sraise \1(\2)\\n"/; }'

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py | 52 +++++++++++++--------------
 nfs4.0/nfs4state.py                   | 28 +++++++--------
 nfs4.1/config.py                      |  2 +-
 nfs4.1/nfs4state.py                   |  4 +--
 xdr/xdrgen.py                         | 22 ++++++------
 5 files changed, 54 insertions(+), 54 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
index 2c68875..6351355 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
@@ -127,8 +127,8 @@ class SecAuthGss(SecFlavor):
         self.gss_seq_num = 0
         d = gssapi.importName("nfs@%s" % client.remotehost)
         if d['major'] != gssapi.GSS_S_COMPLETE:
-            raise SecError, "gssapi.importName returned: %s" % \
-                  show_major(d['major'])
+            raise SecError("gssapi.importName returned: %s" % \
+                  show_major(d['major']))
         name = d['name']
         # We need to send NULLPROCs with token from initSecContext
         good_major = [gssapi.GSS_S_COMPLETE, gssapi.GSS_S_CONTINUE_NEEDED]
@@ -141,11 +141,11 @@ class SecAuthGss(SecFlavor):
             major = d['major']
             context = d['context']
             if major not in good_major:
-                raise SecError, "gssapi.initSecContext returned: %s" % \
-                      show_major(major)
+                raise SecError("gssapi.initSecContext returned: %s" % \
+                      show_major(major))
             if (major == gssapi.GSS_S_CONTINUE_NEEDED) and \
                    (reply_major == gssapi.GSS_S_COMPLETE):
-                raise SecError, "Unexpected GSS_S_COMPLETE from server"
+                raise SecError("Unexpected GSS_S_COMPLETE from server")
             token = d['token']
             if reply_major != gssapi.GSS_S_COMPLETE:
                 # FRED - sec 5.2.2 of RFC 2203 mentions possibility that
@@ -161,13 +161,13 @@ class SecAuthGss(SecFlavor):
                 up.done()
                 reply_major = res.gss_major
                 if reply_major not in good_major:
-                    raise SecError, "Server returned: %s" % \
-                          show_major(reply_major)
+                    raise SecError("Server returned: %s" % \
+                          show_major(reply_major))
                 self.init = 2
                 reply_token = res.gss_token
             if major == gssapi.GSS_S_COMPLETE:
                 if reply_major != gssapi.GSS_S_COMPLETE:
-                    raise SecError, "Unexpected COMPLETE from client"
+                    raise SecError("Unexpected COMPLETE from client")
                 break
         self.gss_context = context
         self.gss_handle = res.handle
@@ -240,8 +240,8 @@ class SecAuthGss(SecFlavor):
             d = gssapi.getMIC(self.gss_context, data)
             major = d['major']
             if major != gssapi.GSS_S_COMPLETE:
-                raise SecError, "gssapi.getMIC returned: %s" % \
-                      show_major(major)
+                raise SecError("gssapi.getMIC returned: %s" % \
+                      show_major(major))
             return opaque_auth(RPCSEC_GSS, d['token'])
         
     def _make_cred_gss(self, handle, service, gss_proc=RPCSEC_GSS_DATA, seq=0):
@@ -266,8 +266,8 @@ class SecAuthGss(SecFlavor):
             data = p.get_buffer() + data
             d = gssapi.getMIC(self.gss_context, data)
             if d['major'] != gssapi.GSS_S_COMPLETE:
-                raise SecError, "gssapi.getMIC returned: %s" % \
-                      show_major(d['major'])
+                raise SecError("gssapi.getMIC returned: %s" % \
+                      show_major(d['major']))
             p.reset()
             p.pack_opaque(data)
             p.pack_opaque(d['token'])
@@ -280,14 +280,14 @@ class SecAuthGss(SecFlavor):
             data = p.get_buffer() + data
             d = gssapi.wrap(self.gss_context, data)
             if d['major'] != gssapi.GSS_S_COMPLETE:
-                raise SecError, "gssapi.wrap returned: %s" % \
-                      show_major(d['major'])
+                raise SecError("gssapi.wrap returned: %s" % \
+                      show_major(d['major']))
             p.reset()
             p.pack_opaque(d['msg'])
             data = p.get_buffer()
         else:
             # Not really necessary, should have already raised XDRError
-            raise SecError, "Unknown service %i for RPCSEC_GSS" % gss_cred.service
+            raise SecError("Unknown service %i for RPCSEC_GSS" % gss_cred.service)
         return data
 
     def unsecure_data(self, data, cred):
@@ -305,14 +305,14 @@ class SecAuthGss(SecFlavor):
             p.done()
             d = gssapi.verifyMIC(self.gss_context, data, checksum)
             if d['major'] != gssapi.GSS_S_COMPLETE:
-                raise SecError, "gssapi.verifyMIC returned: %s" % \
-                      show_major(d['major'])
+                raise SecError("gssapi.verifyMIC returned: %s" % \
+                      show_major(d['major']))
             p.reset(data)
             seqnum = p.unpack_uint()
             if seqnum != gss_cred.seq_num:
-                raise SecError, \
+                raise SecError(\
                       "Mismatched seqnum in reply: got %i, expected %i" % \
-                      (seqnum, gss_cred.seq_num)
+                      (seqnum, gss_cred.seq_num))
             data = p.get_buffer()[p.get_position():]
         elif gss_cred.service == rpc_gss_svc_privacy:
             # data = opaque[wrap([gss_seq_num+data])]
@@ -322,18 +322,18 @@ class SecAuthGss(SecFlavor):
             p.done()
             d = gssapi.unwrap(self.gss_context, data)
             if d['major'] != gssapi.GSS_S_COMPLETE:
-                raise SecError, "gssapi.unwrap returned %s" % \
-                      show_major(d['major'])
+                raise SecError("gssapi.unwrap returned %s" % \
+                      show_major(d['major']))
             p.reset(d['msg'])
             seqnum = p.unpack_uint()
             if seqnum != gss_cred.seq_num:
-                raise SecError, \
+                raise SecError(\
                       "Mismatched seqnum in reply: got %i, expected %i" % \
-                      (seqnum, self.gss_cred.seq_num)
+                      (seqnum, self.gss_cred.seq_num))
             data = p.get_buffer()[p.get_position():]
         else:
             # Not really necessary, should have already raised XDRError
-            raise SecError, "Unknown service %i for RPCSEC_GSS" % gss_cred.service
+            raise SecError("Unknown service %i for RPCSEC_GSS" % gss_cred.service)
         return data
 
     def _gss_cred_from_opaque_auth(self, auth):
@@ -361,8 +361,8 @@ class SecAuthGss(SecFlavor):
         p.pack_uint(i)
         d = gssapi.getMIC(self.gss_context, p.get_buffer())
         if d['major'] != gssapi.GSS_S_COMPLETE:
-            raise SecError, "gssapi.getMIC returned: %s" % \
-                  show_major(d['major'])
+            raise SecError("gssapi.getMIC returned: %s" % \
+                  show_major(d['major']))
         return opaque_auth(RPCSEC_GSS, d['token'])
 
     def check_verf(self, rverf, cred):
diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index 064aadd..e854b3b 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -146,7 +146,7 @@ class NFSServerState:
 
         def addentry(self, entry):
             if not isinstance(entry, self.CacheEntry):
-                raise TypeError, "Bad entry: %s" % str(entry)
+                raise TypeError("Bad entry: %s" % str(entry))
             if self.exists(x=entry.x) or self.exists(c=entry.c):
                 raise "Bad Cache"
             self.list.append(entry)
@@ -200,7 +200,7 @@ class NFSServerState:
             elif isinstance(owner, lock_owner4):
                 self.openid = openid
             else:
-                raise TypeError, "Passed in owner = %s" % str(owner)
+                raise TypeError("Passed in owner = %s" % str(owner))
             # An owner is confirmed with OpenConfirm, a lock by sending stateid
             self.confirmed = False
             self.owner = owner
@@ -323,7 +323,7 @@ class NFSServerState:
         Conflict will raise NFS4Error.
         """
         if not isinstance(owner, open_owner4):
-            raise TypeError, "Owner was given as %s" % str(owner)
+            raise TypeError("Owner was given as %s" % str(owner))
         info = self.__getinfo(owner)
         if not info.confirmed:
             # Remove any pending open (RFC 3530 sec 14.2.18)
@@ -380,7 +380,7 @@ class NFSServerState:
     def __state2id(self, stateid, checkseq=False):
         """Translate nfs4 stateid to internal id"""
         if not isinstance(stateid, stateid4):
-            raise TypeError, "State was given as %s" % str(stateid)
+            raise TypeError("State was given as %s" % str(stateid))
         # Check for special stateids
         if stateid.seqid==0 and stateid.other==chr(0)*12:
             return 0
@@ -407,11 +407,11 @@ class NFSServerState:
         info = self.__owner2info(owner, allownew)
         try:
             if fh is None:
-                raise ValueError, "File is None"
+                raise ValueError("File is None")
             return info.files[fh.handle]
         except KeyError:
             if not allownew:
-                raise ValueError, "File %s not open for %s" % (fh.name, info)
+                raise ValueError("File %s not open for %s" % (fh.name, info))
             #print("Creating new id %i for fh %s" % (self.next_id, fh.handle))
             id = info.files[fh.handle] = self.next_id
             self.next_id += 1
@@ -428,12 +428,12 @@ class NFSServerState:
         elif isinstance(owner, lock_owner4):
             ownerdict = self.lockowners
         else:
-            raise TypeError, "Gave owner as %s" % str(owner)
+            raise TypeError("Gave owner as %s" % str(owner))
         self.__check_clientid(owner.clientid)
         try:
             info = ownerdict[owner.clientid][owner.owner]
         except KeyError:
-            if not allownew: raise ValueError, "Unknown owner %s" % str(owner)
+            if not allownew: raise ValueError("Unknown owner %s" % str(owner))
             #print("Creating new info")
             info = self.OwnerInfo(owner)
             if owner.clientid in ownerdict:
@@ -694,8 +694,8 @@ class NFSFileState:
             self.start = start
             self.end = end
             if start < 0 or end < start:
-                raise ValueError, "Bad values for start and end (%s, %s)" % \
-                                  (start, end)
+                raise ValueError("Bad values for start and end (%s, %s)" % \
+                                  (start, end))
 
         def __repr__(self):
             if self.type & 1: str = "READ"
@@ -1478,7 +1478,7 @@ class DirList:
         for x in self.list:
             if x.name == name:
                 return x.fh
-        raise KeyError, "Invalid key %s" % name
+        raise KeyError("Invalid key %s" % name)
 
     def __setitem__(self, name, fh):
         """Allows self[name] = fh"""
@@ -1499,18 +1499,18 @@ class DirList:
             if x.name == name:
                 self.list.remove(x)
                 return
-        raise KeyError, "Invalid key %s" % name
+        raise KeyError("Invalid key %s" % name)
 
     def getcookie(self, name):
         for x in self.list:
             if x.name == name:
                 return x.cookie
-        raise KeyError, "Invalid key %s" % name
+        raise KeyError("Invalid key %s" % name)
 
     def readdir(self, cookie):
         """Returns DirEnt list containing all entries larger than cookie"""
         if cookie < 0 or cookie > self.__lastcookie:
-            raise IndexError, "Invalid cookie %i" % cookie
+            raise IndexError("Invalid cookie %i" % cookie)
         i = None
         for x in self.list:
             if x.cookie > cookie:
diff --git a/nfs4.1/config.py b/nfs4.1/config.py
index 23b5b9a..b4a45d7 100644
--- a/nfs4.1/config.py
+++ b/nfs4.1/config.py
@@ -56,7 +56,7 @@ def _opline(value):
         l = value
     else:
         print('                 OPLINE type ', type(value))
-        raise TypeError, 'Only type list or str accepted'
+        raise TypeError('Only type list or str accepted')
     if l[0] == "ERROR":
         if not len(l) == 3:
             print('                 OPLINE length ', len)
diff --git a/nfs4.1/nfs4state.py b/nfs4.1/nfs4state.py
index 2214c0d..95f84df 100644
--- a/nfs4.1/nfs4state.py
+++ b/nfs4.1/nfs4state.py
@@ -99,8 +99,8 @@ class ByteLock(object):
         self.start = start
         self.end = end
         if start < 0 or end < start:
-            raise ValueError, "Bad values for start and end (%s, %s)" % \
-                              (start, end)
+            raise ValueError("Bad values for start and end (%s, %s)" % \
+                              (start, end))
 
     def __repr__(self):
         str = ("WRITE" if self.iswrite else "READ")
diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 6353835..0aa1a52 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -819,7 +819,7 @@ class Info(object):
                         (prefix, self.id)
                 if self.len is not None:
                     limit = "%sif len(data) > %s:\n" \
-                            "%s%sraise XDRError, 'array length too long'\n" %\
+                            "%s%sraise XDRError('array length too long')\n" %\
                             (prefix, self.fullname(self.len), prefix, varindent)
                     array = limit + array
         else:
@@ -846,7 +846,7 @@ class Info(object):
                          (prefix, newdata, self.id)
                 if self.len is not None:
                     limit = "%sif len(%s) > %s:\n" \
-                            "%s%sraise XDRError, 'array length too long'\n" %\
+                            "%s%sraise XDRError('array length too long')\n" %\
                             (prefix, newdata, self.fullname(self.len), prefix, indent)
                     array += limit
             newdata = 'data'
@@ -858,7 +858,7 @@ class Info(object):
         prefix, data, subheader, array = self._array_pack(prefix, data)
         varlist = ["const.%s" % l.id for l in self.body]
         check = "%sif self.check_enum and %s not in [%s]:\n" \
-                "%s%sraise XDRError, 'value=%%s not in enum %s' %% %s\n" % \
+                "%s%sraise XDRError('value=%%s not in enum %s' %% %s)\n" % \
                 (prefix, data, ', '.join(varlist),
                  prefix, indent, self.id, data)
         pack = check + "%sself.pack_int(%s)\n" % (prefix, data)
@@ -868,7 +868,7 @@ class Info(object):
         prefix, data, subheader, array = self._array_unpack(prefix, data)
         varlist = ["const.%s" % l.id for l in self.body]
         check = "%sif self.check_enum and %s not in [%s]:\n" \
-                "%s%sraise XDRError, 'value=%%s not in enum %s' %% %s\n" % \
+                "%s%sraise XDRError('value=%%s not in enum %s' %% %s)\n" % \
                 (prefix, data, ', '.join(varlist),
                  prefix, indent, self.id, data)
         unpack = "%s%s = self.unpack_int()\n" % (prefix, data)
@@ -908,7 +908,7 @@ class Info(object):
         if default != []:
             pack += default[0].packout(prefix + indent, data)
         else:
-            pack += "%s%sraise XDRError, 'bad switch=%%s' %% %s.%s\n" % \
+            pack += "%s%sraise XDRError('bad switch=%%s' %% %s.%s)\n" % \
                     (prefix, indent, data, switch.id)
         return subheader + pack + array
 
@@ -950,7 +950,7 @@ class Info(object):
 ##                       (prefix, indent, data, data, default[0].id)
 ##             unpack += arm
         else:
-            unpack += "%s%sraise XDRError, 'bad switch=%%s' %% %s.%s\n" % \
+            unpack += "%s%sraise XDRError('bad switch=%%s' %% %s.%s)\n" % \
                       (prefix, indent, data, switch.id)
             
         return subheader + unpack + array
@@ -1220,7 +1220,7 @@ class type_info(Info):
 
     def packout(self, prefix='', data='data'):
         check = "%sif %s.%s is None:\n" \
-                "%s%sraise TypeError, '%s.%s == None'\n" % \
+                "%s%sraise TypeError('%s.%s == None')\n" % \
                 (prefix, data, self.id, prefix, indent, data, self.id)
         if self.type == 'void':
             return prefix + 'pass\n'
@@ -1279,8 +1279,8 @@ class type_info(Info):
             limit = ''
         else:
             limit = "%sif len(%s) > %s and self.check_array:\n" \
-                    "%s%sraise XDRError, " \
-                    "'array length too long for %s'\n" % \
+                    "%s%sraise XDRError(" \
+                    "'array length too long for %s')\n" % \
                     (prefix, data, self.fullname(self.len), prefix, indent, data)
         if self.fixed:
             fixchar = 'f'
@@ -1303,8 +1303,8 @@ class type_info(Info):
             limit = ''
         else:
             limit = "%sif len(%s) > %s and self.check_array:\n" \
-                    "%s%sraise XDRError, " \
-                    "'array length too long for %s'\n" % \
+                    "%s%sraise XDRError(" \
+                    "'array length too long for %s')\n" % \
                     (prefix, data, self.fullname(self.len), prefix, indent, data)
         if self.fixed:
             fixchar = 'f'
-- 
2.17.1

