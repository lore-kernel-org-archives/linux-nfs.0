Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54798 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388391AbeGXIjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:05 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 03/24] pynfs: python3 support plan: "except E,e:" -> "except E as e:"
Date: Tue, 24 Jul 2018 15:33:21 +0800
Message-Id: <20180724073342.5738-3-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

s/except  *([^,]+), *([^ ]+):/except \1 as \2:/

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpc.py                     |  8 +++---
 nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py     |  2 +-
 nfs4.0/nfs4server.py                      | 32 +++++++++++------------
 nfs4.0/nfs4state.py                       |  8 +++---
 nfs4.0/servertests/st_compound.py         |  4 +--
 nfs4.0/servertests/st_create.py           |  2 +-
 nfs4.0/servertests/st_delegation.py       |  4 +--
 nfs4.0/servertests/st_gss.py              | 28 ++++++++++----------
 nfs4.0/servertests/st_link.py             |  2 +-
 nfs4.0/servertests/st_lookup.py           |  6 ++---
 nfs4.0/servertests/st_readdir.py          |  6 ++---
 nfs4.0/servertests/st_remove.py           |  4 +--
 nfs4.0/servertests/st_rename.py           |  6 ++---
 nfs4.0/testserver.py                      |  8 +++---
 nfs4.1/config.py                          |  2 +-
 nfs4.1/fs.py                              |  4 +--
 nfs4.1/nfs4client.py                      |  6 ++---
 nfs4.1/nfs4server.py                      | 24 ++++++++---------
 nfs4.1/server41tests/st_compound.py       |  2 +-
 nfs4.1/server41tests/st_create_session.py |  2 +-
 nfs4.1/server41tests/st_exchange_id.py    |  2 +-
 nfs4.1/server41tests/st_lookup.py         |  4 +--
 nfs4.1/testclient.py                      |  8 +++---
 nfs4.1/testmod.py                         |  8 +++---
 nfs4.1/testserver.py                      |  8 +++---
 rpc/rpc.py                                | 16 ++++++------
 rpc/rpclib.py                             |  4 +--
 rpc/security.py                           |  8 +++---
 28 files changed, 109 insertions(+), 109 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index 48e3093..83a51c4 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -226,7 +226,7 @@ class RPCClient(object):
             try:
                 sock.bind(('', port))
                 return
-            except socket.error, why:
+            except socket.error as why:
                 if why[0] == errno.EADDRINUSE:
                     port += 1
                 else:
@@ -330,7 +330,7 @@ class RPCClient(object):
             self.socket.send_record(header + data)
         except socket.timeout:
             raise
-        except socket.error, e:
+        except socket.error as e:
             print("Got error:", e)
             if self.debug: print("resend", xid)
             try:
@@ -360,7 +360,7 @@ class RPCClient(object):
                 reply = self.socket.recv_record()
             except socket.timeout:
                 raise
-            except socket.error, e:
+            except socket.error as e:
                 print("Got error:", e)
                 if self.debug: print("relisten", xid)
                 try:
@@ -635,7 +635,7 @@ class RPCServer(Server):
         self.rpcunpacker.reset(recv_data)
         try:
             recv_msg = self.rpcunpacker.unpack_rpc_msg()
-        except xdrlib.Error, e:
+        except xdrlib.Error as e:
             print("XDRError", e)
             return
         if recv_msg.body.mtype != CALL:
diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
index 5b5691d..27fc52e 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_sys.py
@@ -18,7 +18,7 @@ class SecAuthSys(SecFlavor):
             p.pack_uint(gid)
             p.pack_array(gids, p.pack_uint)
             self.cred = p.get_buffer()
-        except Error, e:
+        except Error as e:
             raise SecError("Packing error: %s", str(e))
         self.uid = uid
         self.gid = gid
diff --git a/nfs4.0/nfs4server.py b/nfs4.0/nfs4server.py
index d5aea34..cb3ea72 100755
--- a/nfs4.0/nfs4server.py
+++ b/nfs4.0/nfs4server.py
@@ -227,7 +227,7 @@ class NFS4Server(rpc.RPCServer):
                 raise NFS4Error(NFS4ERR_NOFILEHANDLE)
             print("  CLOSE fh", self.curr_fh.handle)
             self.state.close(stateid)
-        except NFS4Error, e:
+        except NFS4Error as e:
             self.state.advance_seqid(stateid, op, (e.code,))
             return simple_error(e.code)
         # Return a garbage state id
@@ -269,7 +269,7 @@ class NFS4Server(rpc.RPCServer):
             attrset = self.curr_fh.create(op.opcreate.objname, op.opcreate.objtype, attrs)
             new_cinfo = self.curr_fh.fattr4_change
             self.curr_fh = self.curr_fh.lookup(op.opcreate.objname)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         cin4 = change_info4(before=old_cinfo, after=new_cinfo, atomic=1)
         c4resok = CREATE4resok(cinfo=cin4, attrset = attrset)
@@ -290,7 +290,7 @@ class NFS4Server(rpc.RPCServer):
                 return simple_error(NFS4ERR_NOFILEHANDLE)
             attrs = nfs4lib.bitmap2list(op.opgetattr.attr_request)
             attrvals = self.curr_fh.get_attributes(attrs)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         garesok = GETATTR4resok(attrvals)
         return simple_error(NFS4_OK, garesok)
@@ -351,7 +351,7 @@ class NFS4Server(rpc.RPCServer):
                 self.state.new_lockowner(op.oplock.locker.open_owner)
             stateid = self.state.lock(self.curr_fh, owner, op.oplock.locktype,
                                       op.oplock.offset, op.oplock.length)
-        except NFS4Error, e:
+        except NFS4Error as e:
             if op.oplock.locker.new_lock_owner:
                 # FIXME - a bug? compare with replay=check_seqid() above
                 self.state.advance_seqid(openstateid, op, (e.code,))
@@ -376,7 +376,7 @@ class NFS4Server(rpc.RPCServer):
             self.state.testlock(self.curr_fh,
                                 op.oplockt.owner, op.oplockt.locktype,
                                 op.oplockt.offset, op.oplockt.length)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code, e.lock_denied)
         return simple_error(NFS4_OK)
 
@@ -393,7 +393,7 @@ class NFS4Server(rpc.RPCServer):
                 raise NFS4Error(NFS4ERR_NOFILEHANDLE)
             sid = self.state.unlock(self.curr_fh, stateid, op.oplocku.locktype,
                                     op.oplocku.offset, op.oplocku.length)
-        except NFS4Error, e:
+        except NFS4Error as e:
             self.state.advance_seqid(stateid, op, (e.code,))
             return simple_error(e.code)
         self.state.advance_seqid(stateid, op, (NFS4_OK, sid), self.curr_fh)
@@ -438,7 +438,7 @@ class NFS4Server(rpc.RPCServer):
             if FATTR4_RDATTR_ERROR in attrreq:
                 return simple_error(NFS4ERR_INVAL)
             attrvals = self.curr_fh.get_attributes(attrreq.keys(), ignore=False)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         if attrvals == attrreq:
             return simple_error(NFS4ERR_SAME)
@@ -524,7 +524,7 @@ class NFS4Server(rpc.RPCServer):
             # 'existing'  now points to a valid file, so check and set shares
             sid, flags = self.state.open(existing, owner,
                                   op.opopen.share_access, op.opopen.share_deny)
-        except NFS4Error, e:
+        except NFS4Error as e:
             print("Open error")
             self.state.advance_seqid(owner, op, (e.code,))
             return simple_error(e.code)
@@ -560,7 +560,7 @@ class NFS4Server(rpc.RPCServer):
             if self.curr_fh.get_type() != NF4REG:
                 raise NFS4Error(NFS4ERR_INVAL)
             sid = self.state.confirm(self.curr_fh, stateid)
-        except NFS4Error, e:
+        except NFS4Error as e:
             self.state.advance_seqid(stateid, op, (e.code,))
             return simple_error(e.code)
         oc4resok = OPEN_CONFIRM4resok(sid)
@@ -583,7 +583,7 @@ class NFS4Server(rpc.RPCServer):
             sid = self.state.downgrade(self.curr_fh, stateid,
                                        op.opopen_downgrade.share_access,
                                        op.opopen_downgrade.share_deny)
-        except NFS4Error, e:
+        except NFS4Error as e:
             self.state.advance_seqid(stateid, op, (e.code,))
             return simple_error(e.code)
         od4resok = OPEN_DOWNGRADE4resok(sid)
@@ -626,7 +626,7 @@ class NFS4Server(rpc.RPCServer):
                                   offset, count)
             read_data = self.curr_fh.read(offset, count)
             print("  READ DATA: len=%i" % len(read_data))
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         if len(read_data) < count:
             read_eof = 1
@@ -693,7 +693,7 @@ class NFS4Server(rpc.RPCServer):
                 d4 = dirlist4(e4, eof=0)
             else:
                 d4 = dirlist4(e4, eof=1)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         rdresok = READDIR4resok(cookieverf=verifier, reply=d4)
         return simple_error(NFS4_OK, rdresok)
@@ -777,7 +777,7 @@ class NFS4Server(rpc.RPCServer):
     def op_renew(self, op):
         try:
             self.state.renew(op.oprenew.clientid)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         return simple_error(NFS4_OK)
 
@@ -830,7 +830,7 @@ class NFS4Server(rpc.RPCServer):
                 self.state.check_write(self.curr_fh, op.opsetattr.stateid,
                                        offset, length)
             attrset = self.curr_fh.set_attributes(attrdict)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code, e.attrs)
         return simple_error(NFS4_OK, attrset)
 
@@ -908,7 +908,7 @@ class NFS4Server(rpc.RPCServer):
             if FATTR4_RDATTR_ERROR in attrreq:
                 return simple_error(NFS4ERR_INVAL)
             attrvals = self.curr_fh.get_attributes(attrreq.keys(), ignore=False)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         if attrvals == attrreq:
             return simple_error(NFS4_OK)
@@ -935,7 +935,7 @@ class NFS4Server(rpc.RPCServer):
                                    offset, len(data))
             count = self.curr_fh.write(offset, data)
             print("  wrote %i bytes" % count)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return simple_error(e.code)
         w4resok = WRITE4resok(count, FILE_SYNC4, self.state.write_verifier)
         return simple_error(NFS4_OK, w4resok)
diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index fb3fd5c..064aadd 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -249,7 +249,7 @@ class NFSServerState:
             mustexist = True
         try:
             info = self.__getinfo(obj, allownew=not mustexist)
-        except ValueError, e:
+        except ValueError as e:
             if mustexist: raise
         #print("  check_seqid: %s" % info)
         if info is None:
@@ -286,7 +286,7 @@ class NFSServerState:
         # RFC 3530 sec 8.1.5
         try:
             info = self.__getinfo(owner)
-        except (ValueError, NFS4Error):
+        except (ValueError as NFS4Error):
             # An unknown owner, do nothing
             return
         if info is None:
@@ -1132,7 +1132,7 @@ class VirtualHandle(NFSFileHandle):
             except AttributeError:
                 # Otherwise, just set the variable
                 setattr(self, name, attrdict[attr])
-            except NFS4Error, e:
+            except NFS4Error as e:
                 # Note attributes set so far in any error that occurred
                 e.attrs = mapping(ret_list)
                 raise
@@ -1170,7 +1170,7 @@ class VirtualHandle(NFSFileHandle):
         if POSIXACL:
             try:
                 nfs4acl.maps_to_posix(acl)
-            except nfs4acl.ACLError, e:
+            except nfs4acl.ACLError as e:
                 print("*"*50)
                 print(e)
                 print("*"*50)
diff --git a/nfs4.0/servertests/st_compound.py b/nfs4.0/servertests/st_compound.py
index 4919289..59a279d 100644
--- a/nfs4.0/servertests/st_compound.py
+++ b/nfs4.0/servertests/st_compound.py
@@ -82,7 +82,7 @@ def testUndefined(t, env):
             try:
                 res = c.compound([nfs_argop4(argop=opnum)])
                 check(res, NFS4ERR_OP_ILLEGAL, "Sent illegal op=%i" % opnum)
-            except RPCError, e:
+            except RPCError as e:
                 t.fail("COMPOUND with illegal op=%i got %s, "
                        "expected NFS4ERR_OP_ILLEGAL" % (opnum,e))
     finally:
@@ -106,6 +106,6 @@ def testLongCompound(t, env):
                       "COMPOUND with len=%i argarry" % (3*count))
             if res.status == NFS4ERR_RESOURCE:
                 return
-    except RPCError, e:
+    except RPCError as e:
         t.fail("COMPOUND with len=%i argarry got %s, "
                "expected NFS4ERR_RESOURCE" % (3*count, e))
diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
index 7017fdf..ac57aaf 100644
--- a/nfs4.0/servertests/st_create.py
+++ b/nfs4.0/servertests/st_create.py
@@ -290,5 +290,5 @@ def testLongName(t, env):
             (x, rejected_names_create) = self.try_file_names(creator=self.create_via_create)
             self.failIf(rejected_names_open != rejected_names_create,
                         "CREATE does not obey OPEN naming policy")
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
index a2bce04..8e0d891 100644
--- a/nfs4.0/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -21,7 +21,7 @@ class _handle_error(object):
             _lock.acquire()
             try:
                 self.c.compound(ops)
-            except Exception, e:
+            except Exception as e:
                 print("CALLBACK error in _recall:", e)
                 pass
             _lock.release()
@@ -33,7 +33,7 @@ def _recall(c, thisop, cbid):
     _lock.acquire()
     try:
         res = c.compound(ops)
-    except Exception, e:
+    except Exception as e:
         print("CALLBACK error in _recall:", e)
         res = None
     _lock.release()
diff --git a/nfs4.0/servertests/st_gss.py b/nfs4.0/servertests/st_gss.py
index c67a802..414883e 100644
--- a/nfs4.0/servertests/st_gss.py
+++ b/nfs4.0/servertests/st_gss.py
@@ -109,11 +109,11 @@ def testInconsistentGssSeqnum(t, env):
         try:
             res = c.compound([op.putrootfh()])
             e = "operation erroneously suceeding"
-        except rpc.RPCAcceptError, e:
+        except rpc.RPCAcceptError as e:
             if e.stat == rpc.GARBAGE_ARGS:
                 # This is correct response
                 return
-        except Exception, e:
+        except Exception as e:
             pass
         t.fail("Using inconsistent gss_seq_nums in header and body of message "
                "should return GARBAGE_ARGS, instead got %s" % e)
@@ -138,11 +138,11 @@ def testBadVerfChecksum(t, env):
         try:
             res = c.compound([op.putrootfh()])
             e = "peration erroneously suceeding"
-        except rpc.RPCDeniedError, e:
+        except rpc.RPCDeniedError as e:
             if e.stat == rpc.AUTH_ERROR and e.astat == rpc.RPCSEC_GSS_CREDPROBLEM:
                 # This is correct response
                 return
-        except Exception, e:
+        except Exception as e:
             pass
         t.fail("Using bad verifier checksum in header "
                "should return RPCSEC_GSS_CREDPROBLEM, instead got %s" % e)
@@ -174,11 +174,11 @@ def testBadDataChecksum(t, env):
         try:
             res = c.compound([op.putrootfh()])
             e = "operation erroneously suceeding"
-        except rpc.RPCAcceptError, e:
+        except rpc.RPCAcceptError as e:
             if e.stat == rpc.GARBAGE_ARGS:
                 # This is correct response
                 return
-        except Exception, e:
+        except Exception as e:
             pass
         t.fail("Using bad data checksum for body of message "
                "should return GARBAGE_ARGS, instead got %s" % e)
@@ -214,11 +214,11 @@ def testBadVersion(t, env):
             try:
                 res = c.compound([op.putrootfh()])
                 e = "operation erroneously suceeding"
-            except rpc.RPCDeniedError, e:
+            except rpc.RPCDeniedError as e:
                 if e.stat == rpc.AUTH_ERROR and e.astat == rpc.AUTH_BADCRED:
                     # This is correct response
                     e = None
-            except Exception, e:
+            except Exception as e:
                 pass
             if e is not None:
                 t.fail("Using bad gss version number %i "
@@ -241,11 +241,11 @@ def testHighSeqNum(t, env):
         try:
             res = c.compound([op.putrootfh()])
             e = "operation erroneously suceeding"
-        except rpc.RPCDeniedError, e:
+        except rpc.RPCDeniedError as e:
             if e.stat == rpc.AUTH_ERROR and e.astat == rpc.RPCSEC_GSS_CTXPROBLEM:
                 # This is correct response
                 return
-        except Exception, e:
+        except Exception as e:
             pass
         t.fail("Using gss_seq_num over MAXSEQ "
                "should return RPCSEC_GSS_CTXPROBLEM, instead got %s" % e)
@@ -279,11 +279,11 @@ def testBadProcedure(t, env):
             try:
                 res = c.compound([op.putrootfh()])
                 e = "operation erroneously suceeding"
-            except rpc.RPCDeniedError, e:
+            except rpc.RPCDeniedError as e:
                 if e.stat == rpc.AUTH_ERROR and e.astat == rpc.AUTH_BADCRED:
                     # This is correct response
                     e = None
-            except Exception, e:
+            except Exception as e:
                 pass
             if e is not None:
                 t.fail("Using bad gss procedure number %i "
@@ -321,11 +321,11 @@ def testBadService(t, env):
             try:
                 res = c.compound([op.putrootfh()])
                 e = "operation erroneously suceeding"
-            except rpc.RPCDeniedError, e:
+            except rpc.RPCDeniedError as e:
                 if e.stat == rpc.AUTH_ERROR and e.astat == rpc.AUTH_BADCRED:
                     # This is correct response
                     e = None
-            except Exception, e:
+            except Exception as e:
                 pass
             if e is not None:
                 t.fail("Using bad gss service number %i "
diff --git a/nfs4.0/servertests/st_link.py b/nfs4.0/servertests/st_link.py
index 49e0538..feddf1e 100644
--- a/nfs4.0/servertests/st_link.py
+++ b/nfs4.0/servertests/st_link.py
@@ -264,6 +264,6 @@ def testDots(t, env):
             (x, rejected_names_link) = self.try_file_names(creator=self.create_via_link)
             self.failIf(rejected_names_open != rejected_names_link,
                         "LINK does not obey OPEN naming policy")
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
diff --git a/nfs4.0/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
index c3203f9..cd1b93c 100644
--- a/nfs4.0/servertests/st_lookup.py
+++ b/nfs4.0/servertests/st_lookup.py
@@ -312,7 +312,7 @@ def testBadOpaque(t, env):
         res = c.compound([op.putrootfh(), op.lookup("setlength=0xcccccccc")])
         e = "operation erroneously suceeding"
         check(res, NFS4ERR_BADXDR)
-    except rpc.RPCAcceptError, e:
+    except rpc.RPCAcceptError as e:
         if e.stat == rpc.GARBAGE_ARGS:
             # This is correct response
             return
@@ -336,7 +336,7 @@ def testBadOpaque(t, env):
         # Saved files for LOOKUP
         try:
             (accepted_names, rejected_names) = self.try_file_names(0)
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         # Ok, lets try LOOKUP on all accepted names
@@ -363,7 +363,7 @@ def testBadOpaque(t, env):
 
         try:
             (accepted_names, rejected_names) = self.try_file_names()
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         # Ok, lets try LOOKUP on all rejected names
diff --git a/nfs4.0/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
index a88c370..5a70145 100644
--- a/nfs4.0/servertests/st_readdir.py
+++ b/nfs4.0/servertests/st_readdir.py
@@ -272,7 +272,7 @@ def testUnaccessibleDirAttrs(t, env):
         
         try:
             (accepted_names, rejected_names) = self.try_file_names(remove_files=0)
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         fh = self.do_rpc(self.ncl.do_getfh, self.tmp_dir) 
@@ -309,11 +309,11 @@ def testUnaccessibleDirAttrs(t, env):
         
         try:
             (accepted_names, rejected_names) = self.small_try_file_names(remove_files=0)
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         try: self.clean_dir(self.tmp_dir)
-        except SkipException, e:
+        except SkipException as e:
             self.fail(e)
 
     def small_try_file_names(self, remove_files=1, creator=None):
diff --git a/nfs4.0/servertests/st_remove.py b/nfs4.0/servertests/st_remove.py
index 076ca41..5f531f4 100644
--- a/nfs4.0/servertests/st_remove.py
+++ b/nfs4.0/servertests/st_remove.py
@@ -274,7 +274,7 @@ def testNotEmpty(t, env):
         # Save files for REMOVE
         try:
             (accepted_names, rejected_names) = self.try_file_names(remove_files=0)
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         # Ok, lets try REMOVE on all accepted names
@@ -299,7 +299,7 @@ def testNotEmpty(t, env):
         self.init_connection()
         try:
             (accepted_names, rejected_names) = self.try_file_names()
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         # Ok, lets try REMOVE on all rejected names
diff --git a/nfs4.0/servertests/st_rename.py b/nfs4.0/servertests/st_rename.py
index 5698a8c..8f41763 100644
--- a/nfs4.0/servertests/st_rename.py
+++ b/nfs4.0/servertests/st_rename.py
@@ -534,7 +534,7 @@ def testLinkRename(t, env):
             (x, rejected_names_rename) = self.try_file_names(creator=self.create_via_rename)
             self.failIf(rejected_names_open != rejected_names_rename,
                         "RENAME does not obey OPEN naming policy")
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
     def testValidNames(t, env):
@@ -550,7 +550,7 @@ def testLinkRename(t, env):
         # Saved files for 
         try:
             (accepted_names, rejected_names) = self.try_file_names(remove_files=0)
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         # Ok, lets try RENAME on all accepted names
@@ -573,7 +573,7 @@ def testLinkRename(t, env):
 
         try:
             (accepted_names, rejected_names) = self.try_file_names()
-        except SkipException, e:
+        except SkipException as e:
             self.skip(e)
 
         # Ok, lets try RENAME on all rejected names
diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
index c049a5a..96012a1 100755
--- a/nfs4.0/testserver.py
+++ b/nfs4.0/testserver.py
@@ -297,7 +297,7 @@ def main():
                     p.error("Can't use dir for --%s" %attr)
                 try:
                     path = unixpath2comps(path)
-                except Exception, e:
+                except Exception as e:
                     p.error(e)
             setattr(opt, attr, [comp for comp in path if comp])
 
@@ -341,12 +341,12 @@ def main():
     try:
         env = environment.Environment(opt)
         env.init()
-    except socket.gaierror, e:
+    except socket.gaierror as e:
         if e.args[0] == -2:
             print("Unknown server '%s'" % opt.server)
         print(sys.exc_info()[1])
         sys.exit(1)
-    except Exception, e:
+    except Exception as e:
         print("Initialization failed, no tests run.")
         if not opt.maketree:
             print("Perhaps you need to use the --maketree option")
@@ -367,7 +367,7 @@ def main():
     try:
         fail = False
         env.finish()
-    except Exception, e:
+    except Exception as e:
         fail = True
     nfail = testmod.printresults(tests, opt)
     if fail:
diff --git a/nfs4.1/config.py b/nfs4.1/config.py
index 1dbb2ac..23b5b9a 100644
--- a/nfs4.1/config.py
+++ b/nfs4.1/config.py
@@ -74,7 +74,7 @@ class ConfigLine(object):
     def _set_value(self, value):
         try:
             self._value = self.verify(value)
-        except ConfigAction, e:
+        except ConfigAction as e:
             e.name = self.name
             e.value = value
             raise
diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
index 8947014..d9b58f2 100644
--- a/nfs4.1/fs.py
+++ b/nfs4.1/fs.py
@@ -323,7 +323,7 @@ class FSObject(object):
                     base = self.meta
                 try:
                     setattr(base, name, attrs[attr])
-                except NFS4Error, e:
+                except NFS4Error as e:
                     # Note attributes set so far in any error that occurred
                     e.attrs = bitmap
                     raise
@@ -747,7 +747,7 @@ class ConfigObj(FSObject):
             return
         try:
             self.configline.value = lines[0]
-        except ConfigAction, e:
+        except ConfigAction as e:
             if e.name == "reboot":
                 self.fs.server.reboot()
         except:
diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 3e28103..708850d 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -161,7 +161,7 @@ class NFS4Client(rpc.Client, rpc.Server):
                                                        env.results.cache.results))
                 env.cache.data = p.get_buffer()
                 env.cache.valid.set()
-        except NFS4Replay, e:
+        except NFS4Replay as e:
             log_cb.info("Replay...waiting for valid data")
             e.cache.valid.wait()
             log_cb.info("Replay...sending data")
@@ -183,7 +183,7 @@ class NFS4Client(rpc.Client, rpc.Server):
                 return env
         try:
             self.check_utf8str_cs(args.tag)
-        except NFS4Errror, e:
+        except NFS4Errror as e:
             env.results.set_empty_return(e.status, "Invalid utf8 tag")
             return env
         # Handle the individual operations
@@ -202,7 +202,7 @@ class NFS4Client(rpc.Client, rpc.Server):
                 try:
                     # Otherwise, call the function
                     result = funct(arg, env)
-                except NFS4Error, e:
+                except NFS4Error as e:
                     # XXX NOTE this only works for error returns that
                     # include no data.  Must ensure others (eg setattr)
                     # catch error themselves to encode properly.
diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index 8856a82..f8bd251 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -350,7 +350,7 @@ class ClientRecord(object):
                         state.delete()
                     # STUB - what about LAYOUT?
                     # STUB - config whether DELEG OK or not
-            except StandardError, e:
+            except StandardError as e:
                 log_41.exception("Ignoring problem during state removal")
         self.state = {}
         self.lastused = time.time()
@@ -721,7 +721,7 @@ class NFS4Server(rpc.Server):
                                                  env.results.cache.results))
                 env.cache.data = p.get_buffer()
                 env.cache.valid.set()
-        except NFS4Replay, e:
+        except NFS4Replay as e:
             log_41.info("Replay...waiting for valid data")
             e.cache.valid.wait()
             log_41.info("Replay...sending data")
@@ -808,7 +808,7 @@ class NFS4Server(rpc.Server):
             return env
         try:
             self.check_utf8str_cs(args.tag)
-        except NFS4Errror, e:
+        except NFS4Errror as e:
             env.results.set_empty_return(e.status, "Invalid utf8 tag")
             return env
         # Handle the individual operations
@@ -828,7 +828,7 @@ class NFS4Server(rpc.Server):
                 try:
                     # Otherwise, call the function
                     result = funct(arg, env)
-                except NFS4Error, e:
+                except NFS4Error as e:
                     # XXX NOTE this only works for error returns that
                     # include no data.  Must ensure others (eg setattr)
                     # catch error themselves to encode properly.
@@ -876,7 +876,7 @@ class NFS4Server(rpc.Server):
         # We have a session. Check for injected errors
         try:
             self.check_opsconfig(env, "sequence")
-        except NFS4Error, e:
+        except NFS4Error as e:
             self.error_set_session(session, arg.sa_sessionid, e.status)
 
         # Check connection binding
@@ -962,7 +962,7 @@ class NFS4Server(rpc.Server):
                 self.cb_null(session.cb_prog, connection, credinfo=None)
                 flags |= CREATE_SESSION4_FLAG_CONN_BACK_CHAN
                 cb_channel.connections.append(connection)
-            except rpc.RPCError, e:
+            except rpc.RPCError as e:
                 log_41.warn("cb_null failed with %r, no backchannel created", e)
                 # STUB: backchannel is down: set sequence bits, disable layouts, etc.
                 pass
@@ -1604,7 +1604,7 @@ class NFS4Server(rpc.Server):
                 finally:
                     state.mark_done_writing()
             return encode_status(NFS4_OK, bitmap)
-        except NFS4Error, e:
+        except NFS4Error as e:
             # SETATTR failure does not encode just status
             return encode_status(e.status, e.attrs)
 
@@ -1702,7 +1702,7 @@ class NFS4Server(rpc.Server):
             if FATTR4_RDATTR_ERROR in attrreq:
                 raise NFS4Error(NFS4ERR_INVAL)
             attrvals = self.get_attributes(env.cfh, attrreq.keys(), ignore=False)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return encode_status(e.code)
         if attrvals == attrreq:
             return encode_status(NFS4ERR_SAME)
@@ -1717,7 +1717,7 @@ class NFS4Server(rpc.Server):
             if FATTR4_RDATTR_ERROR in attrreq:
                 raise NFS4Error(NFS4ERR_INVAL)
             attrvals = self.get_attributes(env.cfh, attrreq.keys(), ignore=False)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return encode_status(e.code)
         if attrvals != attrreq:
             return encode_status(NFS4ERR_NOT_SAME)
@@ -1806,7 +1806,7 @@ class NFS4Server(rpc.Server):
                 with find_state(env, arg.lock_stateid, allow_0=False) as state:
                     state.add_lock(arg.locktype, arg.offset, end)
                     stateid = state.get_id()
-        except NFS4Error, e:
+        except NFS4Error as e:
             return encode_status(e.status, denied=e.lock_denied)
         l4resok = LOCK4resok(stateid)
         return encode_status(NFS4_OK, l4resok)
@@ -1820,7 +1820,7 @@ class NFS4Server(rpc.Server):
             with env.cfh.state:
                 env.cfh.state.test_lock(env.session.client, arg.owner.owner,
                                         arg.locktype, arg.offset, end)
-        except NFS4Error, e:
+        except NFS4Error as e:
             return encode_status(e.status, denied=e.lock_denied)
         return encode_status(NFS4_OK)
 
@@ -1904,7 +1904,7 @@ class NFS4Server(rpc.Server):
                 return_on_close = False
                 res = LAYOUTGET4resok(return_on_close, entry.get_id(), [layout])
                 return encode_status(NFS4_OK, res)
-        except NFS4Error, e:
+        except NFS4Error as e:
             # LAYOUTGET failure does not encode just status
             if e.status == NFS4ERR_LAYOUTTRYLATER:
                 return encode_status(e.status, None, False)
diff --git a/nfs4.1/server41tests/st_compound.py b/nfs4.1/server41tests/st_compound.py
index 05ad5b3..3915dd8 100644
--- a/nfs4.1/server41tests/st_compound.py
+++ b/nfs4.1/server41tests/st_compound.py
@@ -118,7 +118,7 @@ def testUndefined(t, env):
             check(res, NFS4ERR_OP_ILLEGAL)
             if res.resarray[-1].resop != OP_ILLEGAL:
                 t.fail('Server echoed invalid opcode: Should return OP_ILLEGAL')
-        except RPCAcceptError, e:
+        except RPCAcceptError as e:
             if e.stat == GARBAGE_ARGS:
                 pass
             else:
diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 2ab8ba0..5018ec6 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -311,7 +311,7 @@ def testRdmaArray2(t, env):
     try:
         res = c.listen(xid)
         print(res)
-    except RPCAcceptError, e:
+    except RPCAcceptError as e:
         if e.stat == GARBAGE_ARGS:
             # Legitimate return
             return
diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
index 68f3b09..9becec6 100644
--- a/nfs4.1/server41tests/st_exchange_id.py
+++ b/nfs4.1/server41tests/st_exchange_id.py
@@ -119,7 +119,7 @@ def testLongArray(t, env):
     try:
         res = c.listen(xid)
         print(res)
-    except RPCAcceptError, e:
+    except RPCAcceptError as e:
         if e.stat == GARBAGE_ARGS:
             # Legitimate return
             return
diff --git a/nfs4.1/server41tests/st_lookup.py b/nfs4.1/server41tests/st_lookup.py
index 7ba6918..9f50004 100644
--- a/nfs4.1/server41tests/st_lookup.py
+++ b/nfs4.1/server41tests/st_lookup.py
@@ -360,7 +360,7 @@ if 0:
             # Saved files for LOOKUP
             try:
                 (accepted_names, rejected_names) = self.try_file_names(0)
-            except SkipException, e:
+            except SkipException as e:
                 self.skip(e)
 
             # Ok, lets try LOOKUP on all accepted names
@@ -387,7 +387,7 @@ if 0:
 
             try:
                 (accepted_names, rejected_names) = self.try_file_names()
-            except SkipException, e:
+            except SkipException as e:
                 self.skip(e)
 
             # Ok, lets try LOOKUP on all rejected names
diff --git a/nfs4.1/testclient.py b/nfs4.1/testclient.py
index 8a1be9f..1027fa6 100755
--- a/nfs4.1/testclient.py
+++ b/nfs4.1/testclient.py
@@ -257,7 +257,7 @@ def main():
                     p.error("Can't use dir for --%s" %attr)
                 try:
                     path = nfs4lib.path_components(path)
-                except Exception, e:
+                except Exception as e:
                     p.error(e)
             setattr(opt, attr, [comp for comp in path if comp])
 
@@ -301,11 +301,11 @@ def main():
     try:
         env = environment.Environment(opt)
         env.init()
-    except socket.gaierror, e:
+    except socket.gaierror as e:
         if e.args[0] == -2:
             print("Unknown server '%s'" % opt.server)
         sys.exit(1)
-    except Exception, e:
+    except Exception as e:
         print("Initialization failed, no tests run.")
         if not opt.maketree:
             print("Perhaps you need to use the --maketree option")
@@ -326,7 +326,7 @@ def main():
     try:
         fail = False
         env.finish()
-    except Exception, e:
+    except Exception as e:
         fail = True
     testmod.printresults(tests, opt)
     if fail:
diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index a8b4a82..8108a23 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -226,19 +226,19 @@ class Test(object):
 	    environment.clean_clients()
         except KeyboardInterrupt:
             raise
-        except TestException, e:
+        except TestException as e:
             self.result = Result(e.type, e, sys.exc_info())
-        except StandardError, e:
+        except StandardError as e:
             if verbose:
                 print_exc()
             self.result = Result(TEST_FAIL, '', sys.exc_info())
             self.result.msg = self.result.tb[-1]
-        except Exception, e:
+        except Exception as e:
             self.result = Result(TEST_FAIL, e, sys.exc_info())
             self.result.msg = self.result.tb[-1]
         try:
             environment.shutDown()
-        except StandardError, e:
+        except StandardError as e:
             self.result = Result(TEST_FAIL, '', sys.exc_info())
             self.result.msg = self.result.tb[-1]
 
diff --git a/nfs4.1/testserver.py b/nfs4.1/testserver.py
index 70b4f62..101cfb1 100755
--- a/nfs4.1/testserver.py
+++ b/nfs4.1/testserver.py
@@ -269,7 +269,7 @@ def main():
                     p.error("Can't use dir for --%s" %attr)
                 try:
                     path = nfs4lib.path_components(path)
-                except Exception, e:
+                except Exception as e:
                     p.error(e)
             setattr(opt, attr, [comp for comp in path if comp])
 
@@ -320,12 +320,12 @@ def main():
     try:
         env = environment.Environment(opt)
         env.init()
-    except socket.gaierror, e:
+    except socket.gaierror as e:
         if e.args[0] == -2:
             print("Unknown server '%s'" % opt.server)
         print(sys.exc_info()[1])
         sys.exit(1)
-    except Exception, e:
+    except Exception as e:
         print("Initialization failed, no tests run.")
         if not opt.maketree:
             print("Perhaps you need to use the --maketree option")
@@ -346,7 +346,7 @@ def main():
     try:
         fail = False
         env.finish()
-    except Exception, e:
+    except Exception as e:
         fail = True
     testmod.printresults(tests, opt)
     if fail:
diff --git a/rpc/rpc.py b/rpc/rpc.py
index e06dbbf..834fedd 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -169,7 +169,7 @@ class Alarm(object):
         self._s.setblocking(0)
         try:
             self._s.connect(address)
-        except socket.error, e:
+        except socket.error as e:
             if e.args[0] in [EINPROGRESS, EWOULDBLOCK]:
                 # address has not yet called accept, since this is done in a
                 # single thread, so get "op in progress error".  When the
@@ -330,7 +330,7 @@ class Pipe(object):
             raise RuntimeError
         try:
             count = self._s.send(self._write_buf)
-        except socket.error, e:
+        except socket.error as e:
             log_p.error("flush_pipe got exception %s" % str(e))
             return True # This is to stop retries
         self._write_buf = self._write_buf[count:]
@@ -513,13 +513,13 @@ class ConnectionHandler(object):
             for fd in w:
                 try:
                     self._event_write(fd)
-                except socket.error, e:
+                except socket.error as e:
                     self._event_close(fd)
             for fd in r:
                 if fd in self.listeners:
                     try:
                         self._event_connect_incoming(fd)
-                    except socket.error, e:
+                    except socket.error as e:
                         self._event_close(fd)
                 elif fd == self._alarm_poll.fileno():
                     commands = self._alarm_poll.recv(self.rsize)
@@ -527,7 +527,7 @@ class ConnectionHandler(object):
                         data = self._alarm.pop()
                         try:
                             switch[c](data)
-                        except socket.error, e:
+                        except socket.error as e:
                             self._event_close(fd)
                 else:
                     try:
@@ -557,7 +557,7 @@ class ConnectionHandler(object):
                 s.setblocking(0)
             else:
                 csock, caddr = s.accept()
-        except socket.error, e:
+        except socket.error as e:
             log_p.error("accept() got error %s" % str(e))
             return
         csock.setblocking(0)
@@ -700,7 +700,7 @@ class ConnectionHandler(object):
             # Silently drop the request
             self._notify_drop()
             return
-        except rpclib.RPCFlowContol, e:
+        except rpclib.RPCFlowContol as e:
             body, data = e.body()
         except Exception:
             log_t.warn("Unexpected exception", exc_info=True)
@@ -832,7 +832,7 @@ class ConnectionHandler(object):
             try:
                 s.bind(('', using))
                 return
-            except socket.error, why:
+            except socket.error as why:
                 if why[0] == errno.EADDRINUSE:
                     using += 1
                     if port < 1024 <= using:
diff --git a/rpc/rpclib.py b/rpc/rpclib.py
index e7bb965..e738870 100644
--- a/rpc/rpclib.py
+++ b/rpc/rpclib.py
@@ -33,7 +33,7 @@ class RPCDeniedReply(RPCFlowContol):
             else:
                 # Something has gone haywire
                 rreply = rejected_reply(AUTH_ERROR, astat=AUTH_FAILED)
-        except Exception, e:
+        except Exception as e:
             log.critical("Oops, encountered bug", exc_info=True)
             rreply = rejected_reply(AUTH_ERROR, astat=AUTH_FAILED)
         return reply_body(MSG_DENIED, rreply=rreply), ''
@@ -52,7 +52,7 @@ class RPCUnsuccessfulReply(RPCFlowContol):
                 data = rpc_reply_data(self.stat)
             if self.stat == PROG_MISMATCH:
                 data.mismatch_info = rpc_mismatch_info(*self.statdata)
-        except Exception, e:
+        except Exception as e:
             log.critical("Oops, encountered bug", exc_info=True)
             data = rpc_reply_data(SYSTEM_ERR)
         areply = accepted_reply(NULL_CRED, data)
diff --git a/rpc/security.py b/rpc/security.py
index 1bfb920..896d7a2 100644
--- a/rpc/security.py
+++ b/rpc/security.py
@@ -379,7 +379,7 @@ class AuthGss(AuthNone):
             else:
                 # Can't get here, but doesn't hurt
                 log_gss.error("Unknown service %i for RPCSEC_GSS" % cred.service)
-        except gssapi.Error, e:
+        except gssapi.Error as e:
             log_gss.warn("unsecure_data: gssapi call returned %s" % e.name)
             raise rpclib.RPCUnsuccessfulReply(GARBAGE_ARGS)
         return data
@@ -413,7 +413,7 @@ class AuthGss(AuthNone):
             else:
                 # Can't get here, but doesn't hurt
                 log_gss.error("Unknown service %i for RPCSEC_GSS" % cred.service)
-        except gssapi.Error, e:
+        except gssapi.Error as e:
             # XXX What now?
             log_gss.warn("secure_data: gssapi call returned %s" % e.name)
             raise
@@ -449,7 +449,7 @@ class AuthGss(AuthNone):
             data = self.partially_packed_header(xid, body)
             try:
                 qop = self._get_context(body.cred.body.handle).verifyMIC(data, body.verf.body)
-            except gssapi.Error, e:
+            except gssapi.Error as e:
                 log_gss.warn("Verifier checksum failed verification with %s" %
                              e.name)
                 return False
@@ -522,7 +522,7 @@ class AuthGss(AuthNone):
             context = self._get_context(cred.body.handle)
         try:
             token = context.accept(token)
-        except gssapi.Error, e:
+        except gssapi.Error as e:
             log_gss.debug("RPCSEC_GSS_INIT failed (%s, %i)!" %
                           (e.name, e.minor))
             res = rpc_gss_init_res('', e.major, e.minor, 0, '')
-- 
2.17.1

