Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:53054 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727179AbeGTKAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Jul 2018 06:00:45 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 1/2] pynfs: python3 support plan: print -> print()
Date: Fri, 20 Jul 2018 17:13:10 +0800
Message-Id: <20180720091311.28569-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.0/lib/rpc/rpc.py                      |  54 +++----
 nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py      |   8 +-
 nfs4.0/nfs4acl.py                          |   2 +-
 nfs4.0/nfs4client.py                       |  12 +-
 nfs4.0/nfs4lib.py                          |  16 +-
 nfs4.0/nfs4server.py                       | 166 ++++++++++-----------
 nfs4.0/nfs4state.py                        |  32 ++--
 nfs4.0/servertests/environment.py          |  12 +-
 nfs4.0/servertests/st_delegation.py        |   6 +-
 nfs4.0/servertests/st_fslocations.py       |  22 +--
 nfs4.0/servertests/st_getattr.py           |  10 +-
 nfs4.0/servertests/st_reboot.py            |   2 +-
 nfs4.0/testserver.py                       |  30 ++--
 nfs4.1/block.py                            |   8 +-
 nfs4.1/client41tests/ct_reboot.py          |  10 +-
 nfs4.1/client41tests/environment.py        |   2 +-
 nfs4.1/config.py                           |  10 +-
 nfs4.1/errorparser.py                      |   2 +-
 nfs4.1/locking.py                          |   6 +-
 nfs4.1/nfs4lib.py                          |   6 +-
 nfs4.1/nfs4proxy.py                        |   2 +-
 nfs4.1/nfs4server.py                       |  14 +-
 nfs4.1/server41tests/environment.py        |   6 +-
 nfs4.1/server41tests/st_block.py           |  24 +--
 nfs4.1/server41tests/st_create_session.py  |   6 +-
 nfs4.1/server41tests/st_debug.py           |  10 +-
 nfs4.1/server41tests/st_destroy_session.py |   2 +-
 nfs4.1/server41tests/st_exchange_id.py     |   4 +-
 nfs4.1/server41tests/st_getdevicelist.py   |  14 +-
 nfs4.1/server41tests/st_secinfo_no_name.py |   2 +-
 nfs4.1/setup.py                            |   6 +-
 nfs4.1/testclient.py                       |  30 ++--
 nfs4.1/testmod.py                          |  29 ++--
 nfs4.1/testserver.py                       |  30 ++--
 rpc/rpc.py                                 |   4 +-
 setup.py                                   |   4 +-
 showresults.py                             |   1 +
 xdr/xdrgen.py                              |  34 ++---
 38 files changed, 321 insertions(+), 317 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index 5ef2e3e..7f84b15 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -230,7 +230,7 @@ class RPCClient(object):
                 if why[0] == errno.EADDRINUSE:
                     port += 1
                 else:
-                    print "Could not use low port"
+                    print("Could not use low port")
                     return
 
     def getsocket(self):
@@ -326,13 +326,13 @@ class RPCClient(object):
         header, cred = self.get_call_header(xid, program, version, procedure)
         data = self.security.secure_data(data, cred)
         try:
-            if self.debug: print "send %i" % xid
+            if self.debug: print("send %i" % xid)
             self.socket.send_record(header + data)
         except socket.timeout:
             raise
         except socket.error, e:
-            print "Got error:", e
-            if self.debug: print "resend", xid
+            print("Got error:", e)
+            if self.debug: print("resend", xid)
             try:
                 self.reconnect().send_record(header + data)
             except socket.error:
@@ -346,7 +346,7 @@ class RPCClient(object):
         # If xid not on list, return error.
         # Listen until get reply with given xid.  Cache others received
         # on list.  Return error if get one not on list.
-        if self.debug: print "listen", xid
+        if self.debug: print("listen", xid)
         list = self.get_outstanding_xids()
         if xid not in list:
             raise
@@ -361,8 +361,8 @@ class RPCClient(object):
             except socket.timeout:
                 raise
             except socket.error, e:
-                print "Got error:", e
-                if self.debug: print "relisten", xid
+                print("Got error:", e)
+                if self.debug: print("relisten", xid)
                 try:
                     s = self.reconnect()
                     s.send_record(list[xid].header + list[xid].data)
@@ -472,21 +472,21 @@ class Server(object):
 
     def run(self, debug=0):
         while 1:
-            if debug: print "%s: Calling poll" % self.name
+            if debug: print("%s: Calling poll" % self.name)
             res = self.p.poll()
-            if debug: print "%s: %s" % (self.name, res)
+            if debug: print("%s: %s" % (self.name, res))
             for fd, event in res:
                 if debug:
-                    print "%s: Handling fd=%i, event=%x" % \
-                          (self.name, fd, event)
+                    print("%s: Handling fd=%i, event=%x" % \
+                          (self.name, fd, event))
                 if event & select.POLLHUP:
                     self.event_hup(fd)
                 elif event & select.POLLNVAL:
-                    if debug: print "%s: POLLNVAL for fd=%i" % (self.name, fd)
+                    if debug: print("%s: POLLNVAL for fd=%i" % (self.name, fd))
                     self.p.unregister(fd)
                 elif event & ~(select.POLLIN | select.POLLOUT):
-                    print "%s: ERROR: event %i for fd %i" % \
-                          (self.name, event, fd)
+                    print("%s: ERROR: event %i for fd %i" % \
+                          (self.name, event, fd))
                     self.event_error(fd)
                 else:
                     if event & select.POLLOUT:
@@ -534,9 +534,9 @@ class RPCServer(Server):
         csock, caddr = self.s.accept()
         csock.setblocking(0)
         if debug:
-            print "SERVER: got connection from %s, " \
+            print("SERVER: got connection from %s, " \
                   "assigned to fd=%i" % \
-                  (csock.getpeername(), csock.fileno())
+                  (csock.getpeername(), csock.fileno()))
         self.p.register(csock, _readmask)
         cfd = csock.fileno()
         self.readbufs[cfd] = ''
@@ -550,7 +550,7 @@ class RPCServer(Server):
 
         Also responds to command codes sent as encoded integers
         """
-        if debug: print "SERVER: In read event for %i" % fd
+        if debug: print("SERVER: In read event for %i" % fd)
         self.readbufs[fd] += data
         loop = True
         while loop:
@@ -566,7 +566,7 @@ class RPCServer(Server):
                     if self.readbufs[fd]:
                         loop = True # We've received data past last 
                     if last:
-                        if debug: print "SERVER: Received record from %i" % fd
+                        if debug: print("SERVER: Received record from %i" % fd)
                         recv_data = ''.join(self.packetbufs[fd])
                         self.packetbufs[fd] = []
                         if len(recv_data) == 4:
@@ -579,14 +579,14 @@ class RPCServer(Server):
                             self.p.register(fd, _bothmask)
 
     def event_write(self, fd, chunksize=2048, debug=0):
-        if debug: print "SERVER: In write event for %i" % fd
+        if debug: print("SERVER: In write event for %i" % fd)
         if self.writebufs[fd]:
-            if debug: print "  writing from writebuf"
+            if debug: print("  writing from writebuf")
             count = self.sockets[fd].send(self.writebufs[fd])
             self.writebufs[fd] = self.writebufs[fd][count:]
             # check if done?
         elif self.recordbufs[fd]:
-            if debug: print "  writing from recordbuf"
+            if debug: print("  writing from recordbuf")
             data = self.recordbufs[fd][0]
             chunk = data[:chunksize]
             if len(data) > chunksize:
@@ -601,12 +601,12 @@ class RPCServer(Server):
             count = self.sockets[fd].send(self.writebufs[fd])
             self.writebufs[fd] = self.writebufs[fd][count:]
         else:
-            if debug: print "  done writing"
+            if debug: print("  done writing")
             self.p.register(fd, _readmask)
 
     def event_command(self, cfd, comm, debug=0):
         if debug:
-            print "SERVER: command = %i, cfd = %i" % (comm, cfd)
+            print("SERVER: command = %i, cfd = %i" % (comm, cfd))
         if comm == 0: # Turn off server
             self.compute_reply = lambda x: None
             return '\0'*4
@@ -616,7 +616,7 @@ class RPCServer(Server):
 
     def event_close(self, fd, debug=0):
         if debug:
-            print "SERVER: closing %i" % fd
+            print("SERVER: closing %i" % fd)
         self.event_error(fd)
 
     def event_error(self, fd):
@@ -636,16 +636,16 @@ class RPCServer(Server):
         try:
             recv_msg = self.rpcunpacker.unpack_rpc_msg()
         except xdrlib.Error, e:
-            print "XDRError", e
+            print("XDRError", e)
             return
         if recv_msg.body.mtype != CALL:
-            print "Received a REPLY, expected a CALL"
+            print("Received a REPLY, expected a CALL")
             return
         # Check for reasons to deny the call
         call = recv_msg.body.cbody
         cred = call.cred
         flavor = cred.flavor
-        #print call
+        #print(call)
         reply_stat = MSG_ACCEPTED
         areply = rreply = None
         proc_response = ''
diff --git a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
index 314924b..2c68875 100644
--- a/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
+++ b/nfs4.0/lib/rpc/rpcsec/sec_auth_gss.py
@@ -204,7 +204,7 @@ class SecAuthGss(SecFlavor):
             p.done()
             d = gssapi.acceptSecContext(token, body.handle)
             if d["major"] == GSS_S_COMPLETE:
-                print "SUCCESS!"
+                print("SUCCESS!")
                 class C(object):
                     pass
                 out = C()
@@ -223,11 +223,11 @@ class SecAuthGss(SecFlavor):
             else:
                 out = hint_string(d)
                 if out is not None:
-                    print out
+                    print(out)
                 return rpc.GARBAGE_ARGS, ''
         else:
             # Stub
-            print "Unable to handle gss_proc==%i" % body.gss_proc
+            print("Unable to handle gss_proc==%i" % body.gss_proc)
             return rpc.GARBAGE_ARGS, ''
     def make_verf(self, data):
         """Verifier sent with each RPC call
@@ -374,7 +374,7 @@ class SecAuthGss(SecFlavor):
             p.reset()
             p.pack_uint(cred.seq_num)
             d = gssapi.verifyMIC(self.gss_context, p.get_buffer(), rverf.body)
-            #print "Verify(%i):"%cred.seq_num, show_major(d['major']), show_minor(d['minor'])
+            #print("Verify(%i):"%cred.seq_num, show_major(d['major']), show_minor(d['minor']))
             
         else:
             pass
diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index 8ae32e2..91a0316 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -214,6 +214,6 @@ def printableacl(acl):
     for ace in acl:
         out += "<type=%6s, flag=%2x, access=%8x, who=%s>\n" % \
                (type_str[ace.type], ace.flag, ace.access_mask, ace.who)
-    #print "leaving printableacl with out = %s" % out
+    #print("leaving printableacl with out = %s" % out)
     return out
     
diff --git a/nfs4.0/nfs4client.py b/nfs4.0/nfs4client.py
index 90c8d2c..5887391 100755
--- a/nfs4.0/nfs4client.py
+++ b/nfs4.0/nfs4client.py
@@ -10,7 +10,7 @@
 
 import sys
 if sys.hexversion < 0x02030000:
-    print "Requires python 2.3 or higher"
+    print("Requires python 2.3 or higher")
     sys.exit(1)
 import os
 # Allow to be run stright from package root
@@ -22,7 +22,7 @@ import readline
 try:
     import readline
 except ImportError:
-    print "Module readline not available."
+    print("Module readline not available.")
 #else:
 #    import rlcompleter
 #    readline.parse_and_bind("tab: complete")
@@ -75,11 +75,11 @@ class PyShell(code.InteractiveConsole):
                 return self.locals[attr]
             else:
                 return getattr(inst, attr)
-        #print "\nCalled complete(%s, %i)" % (text, state)
+        #print("\nCalled complete(%s, %i)" % (text, state))
         if text.startswith('.'):
             # XXX TODO - handle array indexing
             line = readline.get_line_buffer()
-            # print "Line: ", repr(line)
+            # print("Line: ", repr(line))
             return None
         vars = text.split('.')
         base = vars[:-1]
@@ -88,7 +88,7 @@ class PyShell(code.InteractiveConsole):
             try:
                 inst = eval('.'.join(base), self.locals)
             except:
-                print "\nFAIL"
+                print("\nFAIL")
                 traceback.print_exc()
                 return None
         else:
@@ -125,7 +125,7 @@ class PyShell(code.InteractiveConsole):
 def main(server):
     c = PyShell(server)
     c.interact("Try COMPOUND([PUTROOTFH()])")
-    print "Goodbye!"
+    print("Goodbye!")
         
 if __name__ == "__main__":
     main(sys.argv[1])
diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
index 600bce0..507a742 100644
--- a/nfs4.0/nfs4lib.py
+++ b/nfs4.0/nfs4lib.py
@@ -199,7 +199,7 @@ class CBServer(rpc.RPCServer):
         rpc.RPCServer.run(self)
 
     def handle_0(self, data, cred):
-        #print "*****CB received NULL******"
+        #print("*****CB received NULL******")
         if data != '':
             return rpc.GARBAGE_ARGS, ''
         else:
@@ -207,7 +207,7 @@ class CBServer(rpc.RPCServer):
     
     def handle_1(self, data, cred):
         """Deal with CB_COMPOUND"""
-        print "*****CB received COMPOUND******"
+        print("*****CB received COMPOUND******")
         self.nfs4unpacker.reset(data)
         ok, results, tag = self.O_CB_Compound()
         try:
@@ -245,7 +245,7 @@ class CBServer(rpc.RPCServer):
         
     # FIXME
     def O_CB_GetAttr(self, op, cbid):
-        print "******* CB_Getattr *******"
+        print("******* CB_Getattr *******")
         self.opcounts[OP_CB_GETATTR] += 1
         if not self.curr_fh:
             return self.simple_status(NFS4ERR_NOFILEHANDLE)
@@ -254,7 +254,7 @@ class CBServer(rpc.RPCServer):
 
     # FIXME
     def O_CB_Recall(self, op, cbid):
-        print "******* CB_Recall (id=%i)********" % cbid
+        print("******* CB_Recall (id=%i)********" % cbid)
         self.opcounts[OP_CB_RECALL] += 1
         if self.recall_funct.get(cbid, None) is not None:
             res = self.recall_funct[cbid](self.client, op, cbid)
@@ -301,7 +301,7 @@ class NFS4Client(rpc.RPCClient):
                 self.cb_control.connect(('127.0.0.1', self.cb_server.port))
                 break
             except socket.error:
-                print "Waiting for Callback server to start"
+                print("Waiting for Callback server to start")
 
     def cb_command(self, comm):
         self.cb_control.sendall('\x80\x00\x00\x04\x00\x00\x00%s' % chr(comm))
@@ -327,7 +327,7 @@ class NFS4Client(rpc.RPCClient):
                                      minorversion=minorversion)
         if SHOW_TRAFFIC:
             print
-            print compoundargs
+            print(compoundargs)
         p = self.nfs4packer
         un_p = self.nfs4unpacker
         p.reset()
@@ -336,7 +336,7 @@ class NFS4Client(rpc.RPCClient):
         un_p.reset(res)
         res = un_p.unpack_COMPOUND4res()
         if SHOW_TRAFFIC:
-            print res
+            print(res)
         un_p.done()
 
         # Do some error checking
@@ -688,7 +688,7 @@ class NFS4Client(rpc.RPCClient):
         #expect = attrs.keys()
         #expect.sort()
         #if attrlist != expect:
-        #    print "WARNING: OPENresok.attrset mismatches requested attrs"
+        #    print("WARNING: OPENresok.attrset mismatches requested attrs")
         fhandle = res.resarray[-1].switch.switch.object
         stateid = res.resarray[-2].switch.switch.stateid
         rflags = res.resarray[-2].switch.switch.rflags
diff --git a/nfs4.0/nfs4server.py b/nfs4.0/nfs4server.py
index 37c1528..ae93cbc 100755
--- a/nfs4.0/nfs4server.py
+++ b/nfs4.0/nfs4server.py
@@ -17,7 +17,7 @@ except:
 
 import sys
 if sys.hexversion < 0x02030000:
-    print "Requires python 2.3 or higher"
+    print("Requires python 2.3 or higher")
     sys.exit(1)
 import os
 # Allow to be run stright from package root
@@ -107,15 +107,15 @@ class NFS4Server(rpc.RPCServer):
 
     def handle_0(self, data, cred):
         print
-        print "******** TCP RPC NULL CALL ********"
-        print "  flavor = %i" % cred.flavor
+        print("******** TCP RPC NULL CALL ********")
+        print("  flavor = %i" % cred.flavor)
         if cred.flavor == rpc.RPCSEC_GSS:
             gss = self.security[cred.flavor]
             body = gss.read_cred(cred.body)
             if body.gss_proc:
                 return gss.handle_proc(body, data)
         if data != '':
-            print "  ERROR - unexpected data"
+            print("  ERROR - unexpected data")
             return rpc.GARBAGE_ARGS, ''
         else:
             return rpc.SUCCESS, ''
@@ -123,12 +123,12 @@ class NFS4Server(rpc.RPCServer):
     def handle_1(self, data, cred):
         self.nfs4unpacker.reset(data)
         print
-        print "********** TCP RPC CALL ***********"
+        print("********** TCP RPC CALL ***********")
         ok, results, tag = self.O_Compound()
         try:
             self.nfs4unpacker.done()
         except XDRError:
-            print repr(self.nfs4unpacker.get_buffer())
+            print(repr(self.nfs4unpacker.get_buffer()))
             
             raise
             return rpc.GARBAGE_ARGS, ''
@@ -166,11 +166,11 @@ class NFS4Server(rpc.RPCServer):
             cmp4args = self.nfs4unpacker.unpack_COMPOUND4args()
             tag = cmp4args.tag
         except: # [XDRError, StandardError]:
-            #print "ERROR"
+            #print("ERROR")
             #raise
             return NFS4ERR_BADXDR, [], tag
-        print "TCP NFSv4 COMPOUND call, tag: %s, n_ops: %d" % \
-              (repr(tag), len(cmp4args.argarray))
+        print("TCP NFSv4 COMPOUND call, tag: %s, n_ops: %d" % \
+              (repr(tag), len(cmp4args.argarray)))
         if cmp4args.minorversion <> 0:
             return NFS4ERR_MINOR_VERS_MISMATCH, [], tag
         if not verify_utf8(tag):
@@ -180,26 +180,26 @@ class NFS4Server(rpc.RPCServer):
         ok = NFS4_OK
         for op in cmp4args.argarray:
             opname = nfs_opnum4.get(op.argop, 'op_illegal')
-            print "*** %s (%d) ***" % (opname, op.argop)
+            print("*** %s (%d) ***" % (opname, op.argop))
             ok, result = getattr(self, opname.lower())(op)
             results += [ result ]
             if ok <> NFS4_OK:
-                print " ! error %s" % nfsstat4[ok]
+                print(" ! error %s" % nfsstat4[ok])
                 break
-        print "Replying. Status %s (%d)" % (nfsstat4[ok], ok)
+        print("Replying. Status %s (%d)" % (nfsstat4[ok], ok))
         return (ok, results, tag)
 
     # FIXME
     def op_access(self, op):
-        print "  CURRENT FILEHANDLE: %s" % self.curr_fh
-        print "  REQUESTED ACCESS: %s" % access2string(op.opaccess.access)
+        print("  CURRENT FILEHANDLE: %s" % self.curr_fh)
+        print("  REQUESTED ACCESS: %s" % access2string(op.opaccess.access))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         all = ACCESS4_READ | ACCESS4_LOOKUP | ACCESS4_MODIFY | \
             ACCESS4_EXTEND | ACCESS4_DELETE | ACCESS4_EXECUTE
         all = ~all
         if op.opaccess.access & all > 0:
-            print "!!!! Received invalid ACCESS bits in op.opaccess.access"
+            print("!!!! Received invalid ACCESS bits in op.opaccess.access")
             return simple_error(NFS4ERR_INVAL)
         a4_supported = self.curr_fh.supported_access()
         # according to page 140 of 3530, we only return the supported
@@ -207,25 +207,25 @@ class NFS4Server(rpc.RPCServer):
         a4_supported = op.opaccess.access & a4_supported
         a4_access = self.curr_fh.evaluate_access()
         a4_access = op.opaccess.access & a4_access # bitwise and
-        print "  RESULT SUPPORTED: %s" % access2string(a4_supported)
-        print "  RESULT ACCESS: %s" % access2string(a4_access)
+        print("  RESULT SUPPORTED: %s" % access2string(a4_supported))
+        print("  RESULT ACCESS: %s" % access2string(a4_access))
         a4resok = ACCESS4resok(a4_supported, a4_access)
         return simple_error(NFS4_OK, a4resok)
 
     def op_close(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
-        print "  SEQID: %i" % op.opclose.seqid
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
+        print("  SEQID: %i" % op.opclose.seqid)
         stateid = op.opclose.open_stateid
         try:
             replay = self.state.check_seqid(stateid, op.opclose.seqid)
             if replay:
                 self.curr_fh, args = self.check_replay(op, replay)
-                print "Replay args = %s"%str(args)
+                print("Replay args = %s"%str(args))
                 return simple_error(*args)
             # Note must cache response, so need to call raise instead of return
             if not self.curr_fh:
                 raise NFS4Error(NFS4ERR_NOFILEHANDLE)
-            print "  CLOSE fh", self.curr_fh.handle
+            print("  CLOSE fh", self.curr_fh.handle)
             self.state.close(stateid)
         except NFS4Error, e:
             self.state.advance_seqid(stateid, op, (e.code,))
@@ -238,7 +238,7 @@ class NFS4Server(rpc.RPCServer):
     # Note: since currently using ram based fs, we lie here (and in write)
     # and pretend all operations are FILE_SYNC4
     def op_commit(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() == NF4DIR:
@@ -251,7 +251,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, c4resok)
 
     def op_create(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         e = verify_name(op.opcreate.objname)
@@ -265,7 +265,7 @@ class NFS4Server(rpc.RPCServer):
         try:
             old_cinfo = self.curr_fh.fattr4_change
             attrs = op.opcreate.createattrs
-            print attrs
+            print(attrs)
             attrset = self.curr_fh.create(op.opcreate.objname, op.opcreate.objtype, attrs)
             new_cinfo = self.curr_fh.fattr4_change
             self.curr_fh = self.curr_fh.lookup(op.opcreate.objname)
@@ -284,7 +284,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4ERR_NOTSUPP)
 
     def op_getattr(self, op):
-        print "  ATTRMASK: %s" % [nfs4lib.get_attr_name(bit) for bit in nfs4lib.bitmap2list(op.opgetattr.attr_request)]
+        print("  ATTRMASK: %s" % [nfs4lib.get_attr_name(bit) for bit in nfs4lib.bitmap2list(op.opgetattr.attr_request)])
         try:
             if not self.curr_fh:
                 return simple_error(NFS4ERR_NOFILEHANDLE)
@@ -298,15 +298,15 @@ class NFS4Server(rpc.RPCServer):
     def op_getfh(self, op):
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
-        print "  FILEHANDLE %s" % self.curr_fh.handle
+        print("  FILEHANDLE %s" % self.curr_fh.handle)
         # XXX BUG - fhcache not set on getattr or readdir(getattr)
         self.fhcache[self.curr_fh.handle] = self.curr_fh
         confirmres = GETFH4resok(str(self.curr_fh.handle))
         return simple_error(NFS4_OK, confirmres)
 
     def op_link(self, op):
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
-        print "  SOURCE OBJECT %s" % op.oplink.newname
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
+        print("  SOURCE OBJECT %s" % op.oplink.newname)
         if self.curr_fh is None or self.saved_fh is None:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() != NF4DIR:
@@ -325,7 +325,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, l4resok)
 
     def op_lock(self, op):
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
         try:
             replay = None
             if op.oplock.locker.new_lock_owner:
@@ -364,7 +364,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, l4resok)
 
     def op_lockt(self, op):
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
 
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
@@ -381,7 +381,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK)
 
     def op_locku(self, op):
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
         stateid = op.oplocku.lock_stateid
         try:
             replay = self.state.check_seqid(stateid, op.oplocku.seqid)
@@ -400,8 +400,8 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, sid)
 
     def op_lookup(self, op):
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
-        print "  REQUESTED OBJECT %s" % op.oplookup.objname
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
+        print("  REQUESTED OBJECT %s" % op.oplookup.objname)
         
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
@@ -418,19 +418,19 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK)
 
     def op_lookupp(self, op):
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() != NF4DIR:
             return simple_error(NFS4ERR_NOTDIR)
         self.curr_fh = self.curr_fh.do_lookupp()
-        print "  PARENT FILEHANDLE %s" % repr(self.curr_fh)
+        print("  PARENT FILEHANDLE %s" % repr(self.curr_fh))
         if self.curr_fh is None:
             return simple_error(NFS4ERR_NOENT)
         return simple_error(NFS4_OK)
 
     def op_nverify(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         try:
@@ -446,11 +446,11 @@ class NFS4Server(rpc.RPCServer):
             return simple_error(NFS4_OK)
 
     def op_open(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
-        print "  SEQID: %i" % op.opopen.seqid
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
+        print("  SEQID: %i" % op.opopen.seqid)
         owner = op.opopen.owner
-        print "  CLIENTID: %d" % owner.clientid
-        print "  OWNER: '%s'" % repr(owner.owner)
+        print("  CLIENTID: %d" % owner.clientid)
+        print("  OWNER: '%s'" % repr(owner.owner))
         try:
             if not self.state.confirmed.exists(c=owner.clientid):
                 if self.state.unconfirmed.exists(c=owner.clientid):
@@ -471,14 +471,14 @@ class NFS4Server(rpc.RPCServer):
             if self.curr_fh.get_type() != NF4DIR:
                 raise NFS4Error(NFS4ERR_NOTDIR)
             filename = op.opopen.claim.file
-            print "  FILE %s" % filename
+            print("  FILE %s" % filename)
             e = verify_name(filename)
             if e: raise NFS4Error(e)
             # At this point we know it is CLAIM_NULL with valid filename and cfh
             attrset = 0L
             ci_old = self.curr_fh.fattr4_change
             if op.opopen.openhow.opentype == OPEN4_CREATE:
-                print "  CREATING FILE."
+                print("  CREATING FILE.")
                 type_reg = createtype4(NF4REG)
                 existing = self.curr_fh.lookup(filename)
                 if existing is not None:
@@ -511,7 +511,7 @@ class NFS4Server(rpc.RPCServer):
                         attrset = self.curr_fh.create(filename, type_reg, attrs)
                         existing = self.curr_fh.lookup(filename)
             else:
-                print "  OPENING EXISTING FILE."
+                print("  OPENING EXISTING FILE.")
                 existing = self.curr_fh.lookup(filename)
                 if existing is None:
                     raise NFS4Error(NFS4ERR_NOENT)
@@ -525,7 +525,7 @@ class NFS4Server(rpc.RPCServer):
             sid, flags = self.state.open(existing, owner,
                                   op.opopen.share_access, op.opopen.share_deny)
         except NFS4Error, e:
-            print "Open error"
+            print("Open error")
             self.state.advance_seqid(owner, op, (e.code,))
             return simple_error(e.code)
         ci_new = self.curr_fh.fattr4_change
@@ -539,12 +539,12 @@ class NFS4Server(rpc.RPCServer):
 
     # FIXME: actually open the attr directory, change the filehandle
     def op_openattr(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         return simple_error(NFS4ERR_NOTSUPP)
 
     def op_open_confirm(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
-        print "  SEQID: %i" % op.opopen_confirm.seqid
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
+        print("  SEQID: %i" % op.opopen_confirm.seqid)
         stateid = op.opopen_confirm.open_stateid
         try:
             replay = self.state.check_seqid(stateid, op.opopen_confirm.seqid,
@@ -568,7 +568,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, oc4resok)
 
     def op_open_downgrade(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         stateid = op.opopen_downgrade.open_stateid
         try:
             replay = self.state.check_seqid(stateid, op.opopen_downgrade.seqid)
@@ -591,7 +591,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, od4resok)
 
     def op_putfh(self, op):
-        print "  FILEHANDLE '%s'" % repr(op.opputfh.object)
+        print("  FILEHANDLE '%s'" % repr(op.opputfh.object))
         # check access!
         if not self.fhcache.has_key(op.opputfh.object):
             return simple_error(NFS4ERR_BADHANDLE)
@@ -599,22 +599,22 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK)
 
     def op_putpubfh(self, op):
-        print "  NEW FILEHANDLE %s" % repr(self.curr_fh)
+        print("  NEW FILEHANDLE %s" % repr(self.curr_fh))
         if self.pubfh is None:
             return simple_error(NFS4ERR_NOTSUPP)
         self.curr_fh = self.pubfh
         return simple_error(NFS4_OK)
 
     def op_putrootfh(self, op):
-        print "  NEW FILEHANDLE %s" % repr(self.curr_fh)
+        print("  NEW FILEHANDLE %s" % repr(self.curr_fh))
         self.curr_fh = self.rootfh
         return simple_error(NFS4_OK)
 
     def op_read(self, op):
         offset = op.opread.offset
         count = op.opread.count
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
-        print "  OFFSET: %d COUNT %d" % (offset, count)
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
+        print("  OFFSET: %d COUNT %d" % (offset, count))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() == NF4DIR:
@@ -625,7 +625,7 @@ class NFS4Server(rpc.RPCServer):
             self.state.check_read(self.curr_fh, op.opread.stateid,
                                   offset, count)
             read_data = self.curr_fh.read(offset, count)
-            print "  READ DATA: len=%i" % len(read_data)
+            print("  READ DATA: len=%i" % len(read_data))
         except NFS4Error, e:
             return simple_error(e.code)
         if len(read_data) < count:
@@ -637,10 +637,10 @@ class NFS4Server(rpc.RPCServer):
 
     def op_readdir(self, op):
         # We ignore dircount hint
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
-        print "  COOKIEVERF: %s, %s" % ( repr(op.opreaddir.cookieverf), repr(op.opreaddir.cookie))
-        print "  DIRCOUNT: %d MAXCOUNT: %d" % ( op.opreaddir.dircount, op.opreaddir.maxcount)
-        print "  ATTRMASK: %s" % [nfs4lib.get_attr_name(bit) for bit in nfs4lib.bitmap2list(op.opreaddir.attr_request)]
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
+        print("  COOKIEVERF: %s, %s" % ( repr(op.opreaddir.cookieverf), repr(op.opreaddir.cookie)))
+        print("  DIRCOUNT: %d MAXCOUNT: %d" % ( op.opreaddir.dircount, op.opreaddir.maxcount))
+        print("  ATTRMASK: %s" % [nfs4lib.get_attr_name(bit) for bit in nfs4lib.bitmap2list(op.opreaddir.attr_request)])
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() != NF4DIR:
@@ -699,19 +699,19 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, rdresok)
 
     def op_readlink(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() != NF4LNK:
             return simple_error(NFS4ERR_INVAL)
         link_text = self.curr_fh.read_link()
-        print "  LINK_TEXT: %s" % link_text
+        print("  LINK_TEXT: %s" % link_text)
         rl4resok = READLINK4resok(link_text)
         return simple_error(NFS4_OK, rl4resok)
 
     def op_remove(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
-        print "  TARGET: %s" % op.opremove.target
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
+        print("  TARGET: %s" % op.opremove.target)
         #XXX: CHECK ACCESS
         if self.curr_fh is None:
             return simple_error(NFS4ERR_NOFILEHANDLE)
@@ -732,10 +732,10 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, r4resok)
 
     def op_rename(self, op):
-        print "  SAVED FILEHANDLE: %s" % repr(self.saved_fh)  # old dir
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh) # new dir
-        print "  OLD NAME: %s" % op.oprename.oldname
-        print "  NEW NAME: %s" % op.oprename.newname
+        print("  SAVED FILEHANDLE: %s" % repr(self.saved_fh)  # old dir)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh) # new dir)
+        print("  OLD NAME: %s" % op.oprename.oldname)
+        print("  NEW NAME: %s" % op.oprename.newname)
         if self.curr_fh is None or self.saved_fh is None:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         oldname = op.oprename.oldname
@@ -782,14 +782,14 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK)
 
     def op_restorefh(self, op):
-        print "  SAVED FILEHANDLE: %s" % repr(self.saved_fh)
+        print("  SAVED FILEHANDLE: %s" % repr(self.saved_fh))
         if not self.saved_fh:
             return simple_error(NFS4ERR_RESTOREFH)
         self.curr_fh = self.saved_fh
         return simple_error(NFS4_OK)
 
     def op_savefh(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         self.saved_fh = self.curr_fh
@@ -798,7 +798,7 @@ class NFS4Server(rpc.RPCServer):
     # FIXME: no idea how to set up NFS4_OK conditions; actually get sec information
     def op_secinfo(self, op):
         # STUB
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() != NF4DIR:
@@ -809,8 +809,8 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, resok)
 
     def op_setattr(self, op):
-        print "  CURRENT FILEHANDLE: %s" % repr(self.curr_fh)
-        print op.opsetattr.obj_attributes
+        print("  CURRENT FILEHANDLE: %s" % repr(self.curr_fh))
+        print(op.opsetattr.obj_attributes)
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE, 0L)
         try:
@@ -835,7 +835,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK, attrset)
 
     def op_setclientid(self, op):
-        print "  ID: %s" % ( op.opsetclientid.client.id)
+        print("  ID: %s" % ( op.opsetclientid.client.id))
         x = op.opsetclientid.client.id
         v = op.opsetclientid.client.verifier
         k = (op.opsetclientid.callback, op.opsetclientid.callback_ident)
@@ -860,7 +860,7 @@ class NFS4Server(rpc.RPCServer):
             # This should never happen
             return simple_error(NFS4ERR_INVAL)
         s = self.nextverf()
-        print "   VERIFIER: %s" % repr(s)
+        print("   VERIFIER: %s" % repr(s))
         self.state.unconfirmed.add(v,x,c,k,s,p)
         resok = SETCLIENTID4resok(c, s)
         return simple_error(NFS4_OK, resok)
@@ -869,7 +869,7 @@ class NFS4Server(rpc.RPCServer):
         c = op.opsetclientid_confirm.clientid
         s = op.opsetclientid_confirm.setclientid_confirm
         p = "Stub" # Principal
-        print "  ARGS, clientid %s, verifier %s" % (c, printverf(s))
+        print("  ARGS, clientid %s, verifier %s" % (c, printverf(s)))
         # NOTE this makes the assumption that only one entry can match c=c
         entry = self.state.confirmed.find(c=c)
         entry2 = self.state.unconfirmed.find(c=c)
@@ -900,7 +900,7 @@ class NFS4Server(rpc.RPCServer):
         return simple_error(NFS4_OK)
             
     def op_verify(self, op):
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         try:
@@ -920,21 +920,21 @@ class NFS4Server(rpc.RPCServer):
     def op_write(self, op):
         offset = op.opwrite.offset
         data = op.opwrite.data
-        print "  CURRENT FILEHANDLE %s" % repr(self.curr_fh)
-        print "  OFFSET: %d COUNT %d" % (offset, len(data))
-        print "  STATEID { seqid: %s other: %s}" % (repr(op.opwrite.stateid.seqid), repr(op.opwrite.stateid.other))
+        print("  CURRENT FILEHANDLE %s" % repr(self.curr_fh))
+        print("  OFFSET: %d COUNT %d" % (offset, len(data)))
+        print("  STATEID { seqid: %s other: %s}" % (repr(op.opwrite.stateid.seqid), repr(op.opwrite.stateid.other)))
         if not self.curr_fh:
             return simple_error(NFS4ERR_NOFILEHANDLE)
         if self.curr_fh.get_type() == NF4DIR:
             return simple_error(NFS4ERR_ISDIR)
         if self.curr_fh.get_type() != NF4REG:
             return simple_error(NFS4ERR_INVAL)
-        #print "  DATA: %s" % op.opwrite.data
+        #print("  DATA: %s" % op.opwrite.data)
         try:
             self.state.check_write(self.curr_fh, op.opwrite.stateid,
                                    offset, len(data))
             count = self.curr_fh.write(offset, data)
-            print "  wrote %i bytes" % count
+            print("  wrote %i bytes" % count)
         except NFS4Error, e:
             return simple_error(e.code)
         w4resok = WRITE4resok(count, FILE_SYNC4, self.state.write_verifier)
@@ -956,10 +956,10 @@ def startup(host, port):
             raise
         #server.register()
     except:
-        print "!! unable to register with portmap"
+        print("!! unable to register with portmap")
         pass
-    print "Python NFSv4 Server, (c) CITI, Regents of the University of Michigan"
-    print "Starting Server, root handle: %s" % rootfh 
+    print("Python NFSv4 Server, (c) CITI, Regents of the University of Michigan")
+    print("Starting Server, root handle: %s" % rootfh )
     server.run()
     try:
         server.unregister()
diff --git a/nfs4.0/nfs4state.py b/nfs4.0/nfs4state.py
index d32da29..fb3fd5c 100755
--- a/nfs4.0/nfs4state.py
+++ b/nfs4.0/nfs4state.py
@@ -244,14 +244,14 @@ class NFSServerState:
         See RFC 3530 sec 8.1.5
         """
         # This is getting too complicated.  Should split off creation
-        #print "  check_seqid: Entered"
+        #print("  check_seqid: Entered")
         if isinstance(obj, stateid4):
             mustexist = True
         try:
             info = self.__getinfo(obj, allownew=not mustexist)
         except ValueError, e:
             if mustexist: raise
-        #print "  check_seqid: %s" % info
+        #print("  check_seqid: %s" % info)
         if info is None:
             # A reserved stateid
             raise NFS4Error(NFS4ERR_BAD_STATEID)
@@ -267,9 +267,9 @@ class NFSServerState:
             info.lastseqid = mod32(-1)
             return
         lastseq = info.lastseqid
-        #print "  check_seqid: new: %s, last: %s" % (seqid, lastseq)
+        #print("  check_seqid: new: %s, last: %s" % (seqid, lastseq))
         if lastseq == seqid:
-            print " ***REPLAY*** "
+            print(" ***REPLAY*** ")
             return info.cached_response
         if not info.confirmed and not open_confirm:
             # RFC 3530 sec 14.2.18
@@ -294,7 +294,7 @@ class NFSServerState:
             # FIXME - does this behave correctly for reserved stateids?
             return
         info.cached_response = (cfh, args, op)
-        #print "  advance_seqid - went from: %s" % info.lastseqid
+        #print("  advance_seqid - went from: %s" % info.lastseqid)
         if args[0] not in [NFS4ERR_STALE_CLIENTID, NFS4ERR_STALE_STATEID,
                            NFS4ERR_BAD_STATEID, NFS4ERR_BAD_SEQID,
                            NFS4ERR_BADXDR, NFS4ERR_RESOURCE,
@@ -303,7 +303,7 @@ class NFSServerState:
                 info.lastseqid = 0
             else:
                 info.lastseqid = mod32(info.lastseqid + 1)
-        #print "  advance_seqid -        to: %s" % info.lastseqid
+        #print("  advance_seqid -        to: %s" % info.lastseqid)
 
     def confirm(self, fh, stateid):
         """Confirm an open"""
@@ -352,7 +352,7 @@ class NFSServerState:
             raise NFS4Error(NFS4ERR_BAD_STATEID)
         info = self.state[id].owner
         fh = self.__getfh(id)
-        #print "Close fh from id", fh.handle
+        #print("Close fh from id", fh.handle)
         # Remove locks from file and deal with associated lockowners
         for lockinfo in info.lockowners:
             if fh.handle in lockinfo.files:
@@ -412,7 +412,7 @@ class NFSServerState:
         except KeyError:
             if not allownew:
                 raise ValueError, "File %s not open for %s" % (fh.name, info)
-            #print "Creating new id %i for fh %s" % (self.next_id, fh.handle)
+            #print("Creating new id %i for fh %s" % (self.next_id, fh.handle))
             id = info.files[fh.handle] = self.next_id
             self.next_id += 1
             self.state[id] = self.StateIDInfo(fh, info)
@@ -434,7 +434,7 @@ class NFSServerState:
             info = ownerdict[owner.clientid][owner.owner]
         except KeyError:
             if not allownew: raise ValueError, "Unknown owner %s" % str(owner)
-            #print "Creating new info"
+            #print("Creating new info")
             info = self.OwnerInfo(owner)
             if owner.clientid in ownerdict:
                 ownerdict[owner.clientid][owner.owner] = info
@@ -853,14 +853,14 @@ class NFSFileState:
                list[i].type == list[i-1].type:
                   list[i-1].end = list[i].end
                   del list[i]
-        print list
+        print(list)
 
     def removeposixlock(self, list, type, start, end):
         """Removes lock from sorted list, splitting existing locks as necessary
         """
         self.__removerange(list, start, end)
         list.sort()
-        print list
+        print(list)
 
     def __removerange(self, list, start, end):
         """Removes locks in given range, shrinking locks that half-overlap"""
@@ -1171,9 +1171,9 @@ class VirtualHandle(NFSFileHandle):
             try:
                 nfs4acl.maps_to_posix(acl)
             except nfs4acl.ACLError, e:
-                print "*"*50
-                print e
-                print "*"*50
+                print("*"*50)
+                print(e)
+                print("*"*50)
                 raise NFS4Error(NFS4ERR_INVAL)
         self.fattr4_acl = acl
         self.fattr4_mode = nfs4acl.acl2mode(acl)
@@ -1257,7 +1257,7 @@ class VirtualHandle(NFSFileHandle):
         # FRED - Note this currently does nothing -
         #      - and should do nothing if link count is positive
         if self.fattr4_numlinks > 0: return
-        #print "destructing: %s" % repr(self)
+        #print("destructing: %s" % repr(self))
         if self.fattr4_type == NF4DIR:
             for subfile in self.dirent.values():
                 subfile.destruct()
@@ -1324,7 +1324,7 @@ class VirtualHandle(NFSFileHandle):
         self.fattr4_change += 1
         try: self.file.seek(offset)
         except MemoryError:
-            print "MemError, offset=%s, count=%s" % (str(offset), str(len(data)))
+            print("MemError, offset=%s, count=%s" % (str(offset), str(len(data))))
             raise
         self.file.write(data)
         self.file.seek(0, 2) # Seek to eof
diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
index 4f37d0f..6719b34 100644
--- a/nfs4.0/servertests/environment.py
+++ b/nfs4.0/servertests/environment.py
@@ -183,7 +183,7 @@ class Environment(testmod.Environment):
             path = tree + [name[type]]
             res = c.create_obj(path, type)
             if res.status != NFS4_OK:
-                print "WARNING - could not create /%s" % '/'.join(path)
+                print("WARNING - could not create /%s" % '/'.join(path))
         c.init_connection()
         fh, stateid = c.create_confirm('maketree', tree + ['file'],
                                        deny=OPEN4_SHARE_DENY_NONE)
@@ -209,18 +209,18 @@ class Environment(testmod.Environment):
 
     def sleep(self, sec, msg=''):
         """Sleep for given seconds"""
-        print "Sleeping for %g seconds:" % sec, msg
+        print("Sleeping for %g seconds:" % sec, msg)
         time.sleep(sec)
-        print "Woke up"
+        print("Woke up")
 
     def serverhelper(self, args):
         """Perform a special operation on the server side (such as
         rebooting the server)"""
         if self.opts.serverhelper is None:
-            print "Manual operation required on server:"
-            print args + " and hit ENTER when done"
+            print("Manual operation required on server:")
+            print(args + " and hit ENTER when done")
             sys.stdin.readline()
-            print "Continuing with test"
+            print("Continuing with test")
         else:
             cmd = self.opts.serverhelper
             if self.opts.serverhelperarg:
diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
index bc4effa..a2bce04 100644
--- a/nfs4.0/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -22,7 +22,7 @@ class _handle_error(object):
             try:
                 self.c.compound(ops)
             except Exception, e:
-                print "CALLBACK error in _recall:", e
+                print("CALLBACK error in _recall:", e)
                 pass
             _lock.release()
             
@@ -34,7 +34,7 @@ def _recall(c, thisop, cbid):
     try:
         res = c.compound(ops)
     except Exception, e:
-        print "CALLBACK error in _recall:", e
+        print("CALLBACK error in _recall:", e)
         res = None
     _lock.release()
     if res is not None and res.status != NFS4_OK:
@@ -260,7 +260,7 @@ def testManyReaddeleg(t, env, funct=_recall, response=NFS4_OK):
             cbids.append(c.cbid)
     if not cbids:
         t.pass_warn("Could not get any read delegations")
-    print "Got %i out of %i read delegations" % (len(cbids), count)
+    print("Got %i out of %i read delegations" % (len(cbids), count))
     # Cause them to be recalled
     fh2, stateid2 = _cause_recall(t, env)
     miss_count = 0
diff --git a/nfs4.0/servertests/st_fslocations.py b/nfs4.0/servertests/st_fslocations.py
index 102db52..442d5a2 100644
--- a/nfs4.0/servertests/st_fslocations.py
+++ b/nfs4.0/servertests/st_fslocations.py
@@ -20,7 +20,7 @@ def testReference(t, env):
     res = c.compound(ops)
     check(res, NFS4ERR_MOVED, "GETFH of path indicated by --usespecial")
     locs = c.do_getattr(FATTR4_FS_LOCATIONS, path)
-    print "After NFS4ERR_MOVED, GETATTR(fs_locations) = %s" % locs
+    print("After NFS4ERR_MOVED, GETATTR(fs_locations) = %s" % locs)
 
 def testReference2(t, env):
     """FSLOCATION test of referral node
@@ -33,7 +33,7 @@ def testReference2(t, env):
     c = env.c1
     path = env.opts.usespecial
     locs = c.do_getattr(FATTR4_FS_LOCATIONS, path)
-    print "After NFS4ERR_MOVED, GETATTR(fs_locations) = %s" % locs
+    print("After NFS4ERR_MOVED, GETATTR(fs_locations) = %s" % locs)
 
 def testReference3(t, env):
     """FSLOCATION test of referral node
@@ -46,7 +46,7 @@ def testReference3(t, env):
     c = env.c1
     path = env.opts.usespecial
     locs = c.do_getattr(FATTR4_FS_LOCATIONS, c.homedir)
-    print "After NFS4ERR_MOVED, GETATTR(fs_locations) = %s" % locs
+    print("After NFS4ERR_MOVED, GETATTR(fs_locations) = %s" % locs)
 
 def testAttr1a(t, env):
     """GETATTR with attributes should return _MOVED
@@ -104,10 +104,10 @@ def testAttr2b(t, env):
     attrlist = [FATTR4_SIZE, FATTR4_FILEHANDLE, FATTR4_RDATTR_ERROR, FATTR4_FSID]
     entries = c.do_readdir(path, attr_request=attrlist)
     moved = [e for e in entries if e.attrdict[FATTR4_RDATTR_ERROR] == NFS4ERR_MOVED]
-    print "RDATTR==MOVED for:", [e.name for e in moved]
+    print("RDATTR==MOVED for:", [e.name for e in moved])
     for e in moved:
         if len(e.attrdict) != 2:
-            print e.attrdict
+            print(e.attrdict)
             t.fail("Expected 2 attrs returned for file %s, got %i" % (e.name, len(e.attrdict)))
         
 def testAttr3a(t, env):
@@ -137,7 +137,7 @@ def testAttr3b(t, env):
     entries = c.do_readdir(path, attr_request=attrlist)
     moved = [e for e in entries if e.name == env.opts.usespecial[-1]][0]
     if len(moved.attrdict) != 3:
-        print moved.attrdict
+        print(moved.attrdict)
         t.fail("Expected 3 attrs returned for file %s, got %i" % (moved.name, len(moved.attrdict)))
         
 def testAttr4a(t, env):
@@ -150,7 +150,7 @@ def testAttr4a(t, env):
     path = env.opts.usespecial
     attrlist = [FATTR4_SIZE, FATTR4_FILEHANDLE, FATTR4_RDATTR_ERROR, FATTR4_FSID, FATTR4_FS_LOCATIONS]
     d = c.do_getattrdict(path, attrlist)
-    print d
+    print(d)
     if len(d) != 3:
         t.fail("Expected 3 attrs returned, got %i" % len(d))
 
@@ -167,10 +167,10 @@ def testAttr4b(t, env):
     attrlist = [FATTR4_SIZE, FATTR4_FILEHANDLE, FATTR4_RDATTR_ERROR, FATTR4_FSID, FATTR4_FS_LOCATIONS]
     entries = c.do_readdir(path, attr_request=attrlist)
     moved = [e for e in entries if e.attrdict[FATTR4_RDATTR_ERROR] == NFS4ERR_MOVED]
-    print "RDATTR==MOVED for:", [e.name for e in moved]
+    print("RDATTR==MOVED for:", [e.name for e in moved])
     for e in moved:
         if len(e.attrdict) != 3:
-            print e.attrdict
+            print(e.attrdict)
             t.fail("Expected 3 attrs returned for file %s, got %i" % (e.name, len(e.attrdict)))
         
 def testAttr5a(t, env):
@@ -183,7 +183,7 @@ def testAttr5a(t, env):
     path = env.opts.usespecial
     attrlist = [FATTR4_SIZE, FATTR4_FILEHANDLE, FATTR4_FSID, FATTR4_FS_LOCATIONS]
     d = c.do_getattrdict(path, attrlist)
-    print d
+    print(d)
     if len(d) != 2:
         t.fail("Expected 3 attrs returned, got %i" % len(d))
 
@@ -201,6 +201,6 @@ def testAttr5b(t, env):
     entries = c.do_readdir(path, attr_request=attrlist)
     moved = [e for e in entries if e.name == env.opts.usespecial[-1]][0]
     if len(moved.attrdict) != 2:
-        print moved.attrdict
+        print(moved.attrdict)
         t.fail("Expected 2 attrs returned for file %s, got %i" % (moved.name, len(moved.attrdict)))
         
diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
index eeffa77..500542d 100644
--- a/nfs4.0/servertests/st_getattr.py
+++ b/nfs4.0/servertests/st_getattr.py
@@ -486,7 +486,7 @@ def testFSLocations(t, env):
     check(res, [NFS4_OK, NFS4ERR_ATTRNOTSUPP], "GETATTR(fs_locations)")
     if res.status == NFS4ERR_ATTRNOTSUPP:
         t.fail_support("fs_locations not a supported attribute")
-    # print res.resarray[-1].obj_attributes
+    # print(res.resarray[-1].obj_attributes)
 
 def testLotsofGetattrsFile(t, env):
     """Send lots of getattrs
@@ -517,7 +517,7 @@ def testOwnerName(t, env):
     check(res, [NFS4_OK, NFS4ERR_ATTRNOTSUPP], "GETATTR(owner)")
     if res.status == NFS4ERR_ATTRNOTSUPP:
         t.fail_support("owner not a supported attribute")
-    # print res.resarray[-1].obj_attributes
+    # print(res.resarray[-1].obj_attributes)
 
 
 ####################################################
@@ -541,9 +541,9 @@ def testOwnerName(t, env):
         res = self.ncl.do_ops(ops)
         self.assert_OK(res)
         print
-        print "From Getattr / - ", res.resarray[-3].obj_attributes
+        print("From Getattr / - ", res.resarray[-3].obj_attributes)
         print
-        print "From Getattr /unix - ", res.resarray[-1].obj_attributes
+        print("From Getattr /unix - ", res.resarray[-1].obj_attributes)
 
         ops = [op.putrootfh()]
         attrmask = nfs4lib.list2bitmap(request)
@@ -561,6 +561,6 @@ def testOwnerName(t, env):
             if not entry.nextentry:
                 self.fail("Could not find mountpoint /unix")
             entry = entry.nextentry[0]
-        print "From Readdir / - ", entry.attrs
+        print("From Readdir / - ", entry.attrs)
         
 
diff --git a/nfs4.0/servertests/st_reboot.py b/nfs4.0/servertests/st_reboot.py
index ecfc61f..33c3a4a 100644
--- a/nfs4.0/servertests/st_reboot.py
+++ b/nfs4.0/servertests/st_reboot.py
@@ -217,7 +217,7 @@ def testRootSquash(t, env):
     oldname = oldowner.split('@')[0]
     if oldname == 'root':
         t.fail_support("No root squashing detected")
-    print "Detected root squashing: root -> %s" % oldname
+    print("Detected root squashing: root -> %s" % oldname)
     
     # Wait for grace period to have *just* expired
     _waitForReboot(c, env)
diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
index 9af7703..c049a5a 100755
--- a/nfs4.0/testserver.py
+++ b/nfs4.0/testserver.py
@@ -27,7 +27,7 @@
 
 import sys
 if sys.hexversion < 0x02050000:
-    print "Requires python 2.5 or higher"
+    print("Requires python 2.5 or higher")
     sys.exit(1)
 import os
 # Allow to be run stright from package root
@@ -217,16 +217,16 @@ def printflags(list):
     command_names = [s.lower()[3:].replace('_', '') \
                      for s in nfs_opnum4.values()]
     list.sort()
-    # First print command names
+    # First print(command names)
     print
     for s in list:
         if s in command_names:
-            print s
+            print(s)
     # Then everything else
     print
     for s in list:
         if s not in command_names:
-            print s
+            print(s)
     
 def main():
     nfail = -1
@@ -251,14 +251,14 @@ def main():
         codes = cdict.keys()
         codes.sort()
         for c in codes:
-            print c
+            print(c)
         sys.exit(0)
 
     if opt.showcodesflags:
         codes = cdict.keys()
         codes.sort()
         for c in codes:
-            print c, "FLAGS:", ', '.join(cdict[c].flags_list)
+            print(c, "FLAGS:", ', '.join(cdict[c].flags_list))
         sys.exit(0)
 
     # Grab server info and set defaults
@@ -285,14 +285,14 @@ def main():
     for attr in dir(opt):
         if attr.startswith('use') and attr != "usefh":
             path = getattr(opt, attr)
-            #print attr, path
+            #print(attr, path)
             if path is None:
                 path = opt.path + ['tree', attr[3:]]
             else:
                 # FIXME - have funct that checks path validity
                 if path[0] != '/':
                     p.error("Need to use absolute path for --%s" % attr)
-                # print path
+                # print(path)
                 if path[-1] == '/' and attr != 'usedir':
                     p.error("Can't use dir for --%s" %attr)
                 try:
@@ -337,21 +337,21 @@ def main():
     # Place tests in desired order
     tests.sort() # FIXME - add options for random sort
 
-    # Run the tests and save/print results
+    # Run the tests and save/print(results)
     try:
         env = environment.Environment(opt)
         env.init()
     except socket.gaierror, e:
         if e.args[0] == -2:
-            print "Unknown server '%s'" % opt.server
-        print sys.exc_info()[1]
+            print("Unknown server '%s'" % opt.server)
+        print(sys.exc_info()[1])
         sys.exit(1)
     except Exception, e:
-        print "Initialization failed, no tests run."
+        print("Initialization failed, no tests run.")
         if not opt.maketree:
-            print "Perhaps you need to use the --maketree option"
+            print("Perhaps you need to use the --maketree option")
         raise
-        print sys.exc_info()[1]
+        print(sys.exc_info()[1])
         sys.exit(1)
     if opt.outfile is not None:
         fd = file(opt.outfile, 'w')
@@ -371,7 +371,7 @@ def main():
         fail = True
     nfail = testmod.printresults(tests, opt)
     if fail:
-        print "\nWARNING: could not clean testdir due to:\n%s\n" % str(e)
+        print("\nWARNING: could not clean testdir due to:\n%s\n" % str(e))
 
     if opt.xmlout is not None:
         testmod.xml_printresults(tests, opt.xmlout)
diff --git a/nfs4.1/block.py b/nfs4.1/block.py
index f37bd9b..5ce5ccb 100644
--- a/nfs4.1/block.py
+++ b/nfs4.1/block.py
@@ -159,7 +159,7 @@ class Simple(Volume):
         return pnfs_block_volume4(PNFS_BLOCK_VOLUME_SIMPLE, bv_simple_info=info)
 
     def resolve(self, i):
-        # print "resolve(%i) %r" % (i, self)
+        # print("resolve(%i) %r" % (i, self))
         if i < 0 or i >= self._size:
             raise ValueError("Asked for %i of %i" % (i, self._size))
         return (self, i)
@@ -186,8 +186,8 @@ class Slice(Volume):
         return pnfs_block_volume4(PNFS_BLOCK_VOLUME_SLICE, bv_slice_info=info)
 
     def resolve(self, i):
-        # print "resolve(%i) %r" % (i, self)
-        # print self.start, self._size, self.length
+        # print("resolve(%i) %r" % (i, self))
+        # print(self.start, self._size, self.length)
         if i < 0 or i >= self._size:
             raise ValueError("Asked for %i of %i" % (i, self._size))
         return self.volumes[0].resolve(self.start + i)
@@ -212,7 +212,7 @@ class Concat(Volume):
         return "Concat %i of %r" % (self.id, [v.id for v in self.volumes])
 
     def resolve(self, i):
-        # print "resolve(%i) %r" % (i, self)
+        # print("resolve(%i) %r" % (i, self))
         if i < 0 or i >= self._size:
             raise ValueError("Asked for %i of %i" % (i, self._size))
         sum = 0
diff --git a/nfs4.1/client41tests/ct_reboot.py b/nfs4.1/client41tests/ct_reboot.py
index a5d54a1..3bd241b 100644
--- a/nfs4.1/client41tests/ct_reboot.py
+++ b/nfs4.1/client41tests/ct_reboot.py
@@ -204,12 +204,12 @@ def testTwoValueSetupOrCleanup(t, env):
     echo "Messagetype value value" > $CONFIG/ops/<operation>
 
     """
-    #print 'env.opts.useparams ', env.opts.useparams
+    #print('env.opts.useparams ', env.opts.useparams)
     if len(env.opts.useparams) != 4:
-        print 'TWO_VALUE_SETUP_OR_CLEANUP requires '
-        print 'testclient.py --useparams'
-        print 'Example: --useparams=sequence:ERROR:NFS4ERR_SEQ_MISORDERED:50 '
-        print 'which returns NFS4ERR_SEQ_MISORDERED every 50th sequence op'
+        print('TWO_VALUE_SETUP_OR_CLEANUP requires ')
+        print('testclient.py --useparams')
+        print('Example: --useparams=sequence:ERROR:NFS4ERR_SEQ_MISORDERED:50 ')
+        print('which returns NFS4ERR_SEQ_MISORDERED every 50th sequence op')
         fail("Bad Input to test")
 
     operation = env.opts.useparams[0]
diff --git a/nfs4.1/client41tests/environment.py b/nfs4.1/client41tests/environment.py
index 262c812..8df09aa 100644
--- a/nfs4.1/client41tests/environment.py
+++ b/nfs4.1/client41tests/environment.py
@@ -144,7 +144,7 @@ class Environment(testmod.Environment):
         path = os.path.join(self.root, "config", "ops", opname)
         fd = open(path, "w")
         fd.write(data)
-        print "wait for leasetime: ", lease[1], "seconds"
+        print("wait for leasetime: ", lease[1], "seconds")
         fd.close()
         time.sleep(int(lease[1]))
 
diff --git a/nfs4.1/config.py b/nfs4.1/config.py
index 4747f73..1dbb2ac 100644
--- a/nfs4.1/config.py
+++ b/nfs4.1/config.py
@@ -49,23 +49,23 @@ def _opline(value):
     message-type of error has this form: "ERROR NFS4ERR_code ceiling"
     new message types and more values can be added
     """
-    print '**************** OPLINE typevalue ', type(value)
+    print('**************** OPLINE typevalue ', type(value))
     if type(value) is str:
         l = value.strip().split()
     elif type(value) is list:
         l = value
     else:
-        print '                 OPLINE type ', type(value)
+        print('                 OPLINE type ', type(value))
         raise TypeError, 'Only type list or str accepted'
     if l[0] == "ERROR":
         if not len(l) == 3:
-            print '                 OPLINE length ', len
+            print('                 OPLINE length ', len)
             raise ValueError("ERROR messages only accepts 3 entries")
-        print 'OPLINE len ', len(l)
+        print('OPLINE len ', len(l))
         value = [l[0], _statcode(l[1]), int(l[2])]
     else:
         raise ValueError("Only message-type ERROR accepted")
-    print '**************** OPLINE return ', value
+    print('**************** OPLINE return ', value)
     return value
 
 ###################################################
diff --git a/nfs4.1/errorparser.py b/nfs4.1/errorparser.py
index 3de2052..328fe8d 100755
--- a/nfs4.1/errorparser.py
+++ b/nfs4.1/errorparser.py
@@ -112,7 +112,7 @@ class ErrorParser():
             except IndexError: # function
                 functions = Errors()
                 func = getattr(functions, random.choice(err.function))
-                print func
+                print(func)
                 if callable(func):
                     func(opname, arg, env)
 
diff --git a/nfs4.1/locking.py b/nfs4.1/locking.py
index 7330bbc..1dc428f 100644
--- a/nfs4.1/locking.py
+++ b/nfs4.1/locking.py
@@ -32,7 +32,7 @@ def _collect_acq_data(suffix=""):
     def _deco(acquire):
         def wrapper(self):
             suf = ("" if not suffix else "_%s" % suffix)
-            print "ACQUIRE%s tried for lock %s" % (suf.upper(), self.name)
+            print("ACQUIRE%s tried for lock %s" % (suf.upper(), self.name))
             t = threading.currentThread()
             try:
                 t.locks[self.name] = "waiting%s" % suf
@@ -40,7 +40,7 @@ def _collect_acq_data(suffix=""):
                 t.locks = {self.name: "waiting%s" % suf}
             acquire(self)
             t.locks[self.name] = "holding%s" % suf
-            print "ACQUIRE%s succeeded for lock %s" % (suf.upper(), self.name)
+            print("ACQUIRE%s succeeded for lock %s" % (suf.upper(), self.name))
         return wrapper
     return _deco
 
@@ -49,7 +49,7 @@ def _collect_rel_data(suffix=""):
     def _deco(release):
         def wrapper(self, *args, **kwargs):
             suf = ("" if not suffix else "_%s" % suffix)
-            print "RELEASE%s lock %s" % (suf.upper(), self.name)
+            print("RELEASE%s lock %s" % (suf.upper(), self.name))
             t = threading.currentThread()
             t.locks[self.name] = "released%s" % suf
             release(self, *args, **kwargs)
diff --git a/nfs4.1/nfs4lib.py b/nfs4.1/nfs4lib.py
index 02352e1..96752c2 100644
--- a/nfs4.1/nfs4lib.py
+++ b/nfs4.1/nfs4lib.py
@@ -208,7 +208,7 @@ class FancyNFS4Packer(NFS4Packer):
         """Change simple list of entry4 into strange chain structure"""
         out = []
         for e in data.entries[::-1]:
-            # print "handle", e
+            # print("handle", e)
             # This reverses the direction of the list, so start with reversed
             out = [xdrdef.nfs4_type.entry4(e.cookie, e.name, e.attrs, out)]
         # Must not modify original data structure
@@ -297,10 +297,10 @@ def bitmap2list(bitmap):
 def printhex(str, pretty=True):
     """Print string as hex digits"""
     if pretty:
-        print "".join(["%02x " % ord(c) for c in str])
+        print("".join(["%02x " % ord(c) for c in str]))
     else:
         # Can copy/paste this string
-        print "".join(["\\x%02x" % ord(c) for c in str])
+        print("".join(["\\x%02x" % ord(c) for c in str]))
 
 def str_xor(a, b):
     """xor two string which represent binary data"""
diff --git a/nfs4.1/nfs4proxy.py b/nfs4.1/nfs4proxy.py
index 58c26cb..efb6744 100755
--- a/nfs4.1/nfs4proxy.py
+++ b/nfs4.1/nfs4proxy.py
@@ -69,7 +69,7 @@ class NFS4Proxy(rpc.Server):
             while True:
                 try:
                     server_address = (self.dserver, self.dport)
-                    print server_address
+                    print(server_address)
                     pipe = self.connect(server_address)
                 except:
                     traceback.print_exc(file=sys.stdout)
diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index 7ca4d92..8856a82 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -521,7 +521,7 @@ class SummaryOutput:
         print_summary_line = True
         if summary_line != self._last or role != self._last_role:
             if self._last and self._repeat_count:
-                print "  (repeated %u times)" % self._repeat_count
+                print("  (repeated %u times)" % self._repeat_count)
             self._last = summary_line
             self._repeat_count = 0
         else:
@@ -530,11 +530,11 @@ class SummaryOutput:
 
         if self._last_role != role:
             print
-            print role
+            print(role)
             self._last_role = role
 
         if print_summary_line:
-            print summary_line
+            print(summary_line)
 
 
 ##################################################
@@ -613,7 +613,7 @@ class NFS4Server(rpc.Server):
 
         Note that order matters, since the mount hides anything beneath it.
         """
-        print "Mounting %r on %r" % (fs.fsid, path)
+        print("Mounting %r on %r" % (fs.fsid, path))
         # Find directory object on which to mount fs
         dir = self.root
         principal = nfs4lib.NFS4Principal("root", system=True)
@@ -1964,14 +1964,14 @@ class NFS4Server(rpc.Server):
                 calls.append(call)
             if arg.dir & xdrdef.sctrl_const.DIR_REPLY:
                 replies.append(reply)
-        #print calls
-        #print replies
+        #print(calls)
+        #print(replies)
         grabres = xdrdef.sctrl_type.GRABres(calls, replies)
         return xdrdef.sctrl_const.CTRLSTAT_OK, \
                xdrdef.sctrl_type.resdata_t(arg.ctrlop, grab = grabres)
 
     def ctrl_illegal(self, arg):
-        #print "ILLEGAL"
+        #print("ILLEGAL")
         return xdrdef.sctrl_const.CTRLSTAT_ILLEGAL, xdrdef.sctrl_type.resdata_t(arg.ctrlop)
         
     def op_setclientid(self, arg, env):
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index a910a69..372c9cc 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -225,10 +225,10 @@ class Environment(testmod.Environment):
         """Perform a special operation on the server side (such as
         rebooting the server)"""
         if self.opts.serverhelper is None:
-            print "Manual operation required on server:"
-            print args + " and hit ENTER when done"
+            print("Manual operation required on server:")
+            print(args + " and hit ENTER when done")
             sys.stdin.readline()
-            print "Continuing with test"
+            print("Continuing with test")
         else:
             cmd = self.opts.serverhelper
             if self.opts.serverhelperarg:
diff --git a/nfs4.1/server41tests/st_block.py b/nfs4.1/server41tests/st_block.py
index bf968f9..2041de3 100644
--- a/nfs4.1/server41tests/st_block.py
+++ b/nfs4.1/server41tests/st_block.py
@@ -22,14 +22,14 @@ def testStateid1(t, env):
     # Get layout 1
     fh = res.resarray[-1].object
     open_stateid = res.resarray[-2].stateid
-    print open_stateid
+    print(open_stateid)
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
                         0, 8192, 8192, open_stateid, 0xffff)]
     res = sess.compound(ops)
     check(res)
     lo_stateid = res.resarray[-1].logr_stateid
-    print lo_stateid
+    print(lo_stateid)
     if lo_stateid.seqid != 1:
         # From draft23 12.5.2 "The first successful LAYOUTGET processed by
         # the server using a non-layout stateid as an argument MUST have the
@@ -43,7 +43,7 @@ def testStateid1(t, env):
         res = sess.compound(ops)
         check(res)
         lo_stateid = res.resarray[-1].logr_stateid
-        print lo_stateid
+        print(lo_stateid)
         if lo_stateid.seqid != i + 2:
             # From draft23 12.5.3 "After the layout stateid is established,
             # the server increments by one the value of the "seqid" in each
@@ -63,7 +63,7 @@ def testStateid2(t, env):
     # Get layout 1
     fh = res.resarray[-1].object
     open_stateid = res.resarray[-2].stateid
-    print open_stateid
+    print(open_stateid)
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
                         0, 8192, 8192, open_stateid, 0xffff)]
@@ -71,7 +71,7 @@ def testStateid2(t, env):
     check(res)
     # Get layout 2
     lo_stateid1 = res.resarray[-1].logr_stateid
-    print lo_stateid1
+    print(lo_stateid1)
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
                         8192, 8192, 8192, lo_stateid1, 0xffff)]
@@ -79,14 +79,14 @@ def testStateid2(t, env):
     check(res)
     # Get layout 3 (merge of prior two)
     lo_stateid2 = res.resarray[-1].logr_stateid
-    print lo_stateid2
+    print(lo_stateid2)
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
                         0, 2*8192, 2*8192, lo_stateid2, 0xffff)]
     res = sess.compound(ops)
     check(res)
     lo_stateid3 = res.resarray[-1].logr_stateid
-    print lo_stateid3
+    print(lo_stateid3)
     # lo_stateid3.seqid = 3 # BUG - work around emc problem
     # Parse opaque to get info for commit
     # STUB not very general
@@ -122,7 +122,7 @@ def testEmptyCommit(t, env):
     # Get layout 1
     fh = res.resarray[-1].object
     open_stateid = res.resarray[-2].stateid
-    print open_stateid
+    print(open_stateid)
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
                         0, 8192, 8192, open_stateid, 0xffff)]
@@ -130,14 +130,14 @@ def testEmptyCommit(t, env):
     check(res)
     # Get layout 2
     lo_stateid1 = res.resarray[-1].logr_stateid
-    print lo_stateid1
+    print(lo_stateid1)
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
                         8192, 8192, 8192, lo_stateid1, 0xffff)]
     res = sess.compound(ops)
     check(res)
     lo_stateid2 = res.resarray[-1].logr_stateid
-    print lo_stateid2
+    print(lo_stateid2)
     # Parse opaque to get info for commit
     # STUB not very general
     layout = res.resarray[-1].logr_layout[-1]
@@ -183,7 +183,7 @@ def testSplitCommit(t, env):
     # Get layout 1
     fh = res.resarray[-1].object
     open_stateid = res.resarray[-2].stateid
-    print open_stateid
+    print(open_stateid)
     ops = [op.putfh(fh),
            op.layoutget(False, LAYOUT4_BLOCK_VOLUME, LAYOUTIOMODE4_RW,
                         0, 2*8192, 2*8192, open_stateid, 0xffff)]
@@ -191,7 +191,7 @@ def testSplitCommit(t, env):
     check(res)
 
     lo_stateid1 = res.resarray[-1].logr_stateid
-    print lo_stateid1
+    print(lo_stateid1)
     # Parse opaque to get info for commit
     # STUB not very general
     layout = res.resarray[-1].logr_layout[-1]
diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index bf1eefc..2ab8ba0 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -310,7 +310,7 @@ def testRdmaArray2(t, env):
     xid = c.compound_async(ops, checks=False)
     try:
         res = c.listen(xid)
-        print res
+        print(res)
     except RPCAcceptError, e:
         if e.stat == GARBAGE_ARGS:
             # Legitimate return
@@ -339,7 +339,7 @@ def testCallbackProgram(t, env):
     cb_occurred = threading.Event()
     transient = 0x40000004
     def mycheck(prog):
-        print "Got call using prog=0x%x" % prog
+        print("Got call using prog=0x%x" % prog)
         cb_occurred.prog = prog
         cb_occurred.set()
         return True;
@@ -366,7 +366,7 @@ def testCallbackVersion(t, env):
     cb_occurred = threading.Event()
     transient = 0x40000000
     def mycheck(low, hi, vers):
-        print "Got call using version=%i" % vers
+        print("Got call using version=%i" % vers)
         cb_occurred.low = low
         cb_occurred.hi = hi
         cb_occurred.vers = vers
diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_debug.py
index 532ee7a..e34d03f 100644
--- a/nfs4.1/server41tests/st_debug.py
+++ b/nfs4.1/server41tests/st_debug.py
@@ -31,7 +31,7 @@ def testSupported2(t, env):
                       owner, how, claim)
     res = sess2.compound(env.home + [open_op])
     # STUB - since we are not handling callback, deleg_return never gets done
-    print res
+    print(res)
     check(res)
     fh2 = res.resarray[-1].object
     stateid2 = res.resarray[-2].stateid
@@ -55,16 +55,16 @@ def testReadWrite(t, env):
                       owner, how, claim)
     fh_op = op.putrootfh()
     res = sess1.compound([fh_op, open_op, op.getfh()]) # OPEN
-    print res
+    print(res)
     check(res)
     fh = res.resarray[-1].object
     stateid = res.resarray[-2].stateid
     stateid.seqid = 0
     res = sess1.compound([op.putfh(fh), op.write(stateid, 5, FILE_SYNC4, "write test data")])
-    print res
+    print(res)
     check(res)
     res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 1000)])
-    print res
+    print(res)
     check(res)
     res = close_file(sess1, fh, stateid=stateid)
     check(res)
@@ -95,7 +95,7 @@ def testDeadlock(t, env):
     for xid in xids:
         res = sess1.listen(xid)
         check(res)
-        print res
+        print(res)
     res = close_file(sess1, fh, stateid=stateid)
     check(res)
 
diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index c48d144..466845d 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -109,7 +109,7 @@ def testDestroy3(t, env):
     check(res)
     fh = res.resarray[-1].object
     deleg = res.resarray[-2].delegation
-    print "OPEN fh =", repr(fh)
+    print("OPEN fh =", repr(fh))
     if deleg.delegation_type == OPEN_DELEGATE_NONE:
         fail("Could not get delegation")
     recall.happened = False
diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
index b0ab99c..68f3b09 100644
--- a/nfs4.1/server41tests/st_exchange_id.py
+++ b/nfs4.1/server41tests/st_exchange_id.py
@@ -91,7 +91,7 @@ def testSSV(t, env):
     # This should fail if not using GSS?  What about E_ID?
 
     res = sess.set_ssv('\x5a' * c.protect.context.ssv_len)
-    print res
+    print(res)
     
 def testNoImplId(t, env):
     """Do a simple EXCHANGE_ID w/o setting client impl_id
@@ -118,7 +118,7 @@ def testLongArray(t, env):
     xid = c.compound_async(ops, checks=False)
     try:
         res = c.listen(xid)
-        print res
+        print(res)
     except RPCAcceptError, e:
         if e.stat == GARBAGE_ARGS:
             # Legitimate return
diff --git a/nfs4.1/server41tests/st_getdevicelist.py b/nfs4.1/server41tests/st_getdevicelist.py
index a556ce0..edf5fe4 100644
--- a/nfs4.1/server41tests/st_getdevicelist.py
+++ b/nfs4.1/server41tests/st_getdevicelist.py
@@ -28,7 +28,7 @@ def testGetDevList(t, env):
         check(res)
         # STUB - check block stuff
         dev_list = res.resarray[-1].gdlr_deviceid_list
-        print dev_list
+        print(dev_list)
 
 def testGetDevInfo(t, env):
     """Check devlist
@@ -60,7 +60,7 @@ def testGetDevInfo(t, env):
                 p.reset(res.resarray[-1].da_addr_body)
                 decode = p.unpack_pnfs_block_deviceaddr4()
                 p.done()
-                print decode
+                print(decode)
 
 
 ## def xxxtestLayout(t, env):
@@ -110,7 +110,7 @@ def testGetLayout(t, env):
             p = BlockUnpacker(layout.loc_body)
             opaque = p.unpack_pnfs_block_layout4()
             p.done()
-            print opaque
+            print(opaque)
 
 def testEMCGetLayout(t, env):
     """Verify layout handling
@@ -142,7 +142,7 @@ def testEMCGetLayout(t, env):
             p = BlockUnpacker(layout.loc_body)
             opaque = p.unpack_pnfs_block_layout4()
             p.done()
-            print opaque
+            print(opaque)
 
 def testLayoutReturnFile(t, env):
     """
@@ -257,9 +257,9 @@ def testLayoutCommit(t, env):
         p = BlockUnpacker(layout.loc_body)
         opaque = p.unpack_pnfs_block_layout4()
         p.done()
-        print opaque
+        print(opaque)
     final_extent = opaque.blo_extents[-1]
-    print final_extent
+    print(final_extent)
     if final_extent.bex_state != PNFS_BLOCK_INVALID_DATA:
         fail("Expected INVALID_DATA in extent")
     # LAYOUTCOMMIT
@@ -276,6 +276,6 @@ def testLayoutCommit(t, env):
                            layoutupdate4(LAYOUT4_BLOCK_VOLUME, p.get_buffer()))]
     res = sess.compound(ops)
     check(res)
-    print res
+    print(res)
          
     
diff --git a/nfs4.1/server41tests/st_secinfo_no_name.py b/nfs4.1/server41tests/st_secinfo_no_name.py
index 4c8cb57..9cd6bd3 100644
--- a/nfs4.1/server41tests/st_secinfo_no_name.py
+++ b/nfs4.1/server41tests/st_secinfo_no_name.py
@@ -32,7 +32,7 @@ def testSupported2(t, env):
 
     # GETFH after do a SECINFO_NO_NAME should get error NFS4ERR_NOFILEHANDLE
     res = sess.compound([op.putrootfh(), op.secinfo_no_name(0), op.getfh()])
-    print res
+    print(res)
     check(res, NFS4ERR_NOFILEHANDLE)
 
 def testSupported3(t, env):
diff --git a/nfs4.1/setup.py b/nfs4.1/setup.py
index 5c3a0df..37b99a0 100644
--- a/nfs4.1/setup.py
+++ b/nfs4.1/setup.py
@@ -31,10 +31,10 @@ class build_py(_build_py):
                 self.build_module(module, module_file, package)
 
     def expand_xdr(self, dir):
-        print "expand = %r" % dir
+        print("expand = %r" % dir)
         cwd = os.getcwd()
         xdrdir = os.path.join(cwd, dir, 'xdrdef')
-        print "xdrdir = %r" % xdrdir
+        print("xdrdir = %r" % xdrdir)
         if os.path.exists(xdrdir):
             try:
                 os.chdir(xdrdir)
@@ -47,7 +47,7 @@ class build_py(_build_py):
                         os.remove("parser.out")
                         os.remove("parsetab.py")
                     except:
-                        print "Remove parse* failed"
+                        print("Remove parse* failed")
             finally:
                 os.chdir(cwd)
 
diff --git a/nfs4.1/testclient.py b/nfs4.1/testclient.py
index 95e90e1..8a1be9f 100755
--- a/nfs4.1/testclient.py
+++ b/nfs4.1/testclient.py
@@ -24,7 +24,7 @@
 import use_local # HACK so don't have to rebuild constantly
 import sys
 if sys.hexversion < 0x02050000:
-    print "Requires python 2.5 or higher"
+    print("Requires python 2.5 or higher")
     sys.exit(1)
 import os
 
@@ -197,16 +197,16 @@ def printflags(list):
     command_names = [s.lower()[3:].replace('_', '') \
                      for s in nfs_opnum4.values()]
     list.sort()
-    # First print command names
+    # First print(command names)
     print
     for s in list:
         if s in command_names:
-            print s
+            print(s)
     # Then everything else
     print
     for s in list:
         if s not in command_names:
-            print s
+            print(s)
     
 def main():
     p = OptionParser("%prog SERVER:/PATH [options] flags|testcodes\n"
@@ -228,16 +228,16 @@ def main():
         codes = cdict.keys()
         codes.sort()
         for c in codes:
-            print c
+            print(c)
         sys.exit(0)
 
     # Grab server info and set defaults
     if not args:
         p.error("Need a server")
     url = args.pop(0)
-    print "url", url
+    print("url", url)
     opt.path = nfs4lib.path_components(url)
-    print "Set opt.path", opt.path
+    print("Set opt.path", opt.path)
 
     # Check --use* options are valid
     for attr in dir(opt):
@@ -245,14 +245,14 @@ def main():
             opt.useparams = parse_useparams(opt.useparams)
         elif attr.startswith('use') and attr != "usefh":
             path = getattr(opt, attr)
-            #print attr, path
+            #print(attr, path)
             if path is None:
                 path = opt.path + ['tree', attr[3:]]
             else:
                 # FIXME - have funct that checks path validity
                 if path[0] != '/':
                     p.error("Need to use absolute path for --%s" % attr)
-                # print path
+                # print(path)
                 if path[-1] == '/' and attr != 'usedir':
                     p.error("Can't use dir for --%s" %attr)
                 try:
@@ -297,20 +297,20 @@ def main():
     # Place tests in desired order
     tests.sort() # FIXME - add options for random sort
 
-    # Run the tests and save/print results
+    # Run the tests and save/print(results)
     try:
         env = environment.Environment(opt)
         env.init()
     except socket.gaierror, e:
         if e.args[0] == -2:
-            print "Unknown server '%s'" % opt.server
+            print("Unknown server '%s'" % opt.server)
         sys.exit(1)
     except Exception, e:
-        print "Initialization failed, no tests run."
+        print("Initialization failed, no tests run.")
         if not opt.maketree:
-            print "Perhaps you need to use the --maketree option"
+            print("Perhaps you need to use the --maketree option")
         raise
-        print sys.exc_info()[1]
+        print(sys.exc_info()[1])
         sys.exit(1)
     if opt.outfile is not None:
         fd = file(opt.outfile, 'w')
@@ -330,7 +330,7 @@ def main():
         fail = True
     testmod.printresults(tests, opt)
     if fail:
-        print "\nWARNING: could not clean testdir due to:\n%s\n" % str(e)
+        print("\nWARNING: could not clean testdir due to:\n%s\n" % str(e))
 
 if __name__ == "__main__":
     main()
diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index c5ca0fe..a8b4a82 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -6,6 +6,7 @@
 # Copyright (C) 2004 University of Michigan, Center for 
 #                    Information Technology Integration
 #
+from __future__ import print_function
 from __future__ import with_statement
 import nfs4lib
 import re
@@ -212,11 +213,11 @@ class Test(object):
 
     def run(self, environment, verbose=False):
         """Run self.runtest, storing result"""
-        #print "*********Running test %s (%s)" % (self.name, self.code)
+        #print("*********Running test %s (%s)" % (self.name, self.code))
         self.result = self._run_result
         start_time = time.time()
         if verbose:
-            print repr(self)
+            print(repr(self))
         try:
             environment.startUp()
             self.runtest(self, environment)
@@ -245,7 +246,7 @@ class Test(object):
         self.time_taken = stop_time - start_time
 
         if verbose:
-            print repr(self)
+            print(repr(self))
 
 class Environment(object):
     """Base class for a test environment"""
@@ -419,8 +420,8 @@ def printresults(tests, opts, file=None):
     count = [0] * 6
     for t in tests:
         if not hasattr(t, "result"):
-            print dir(t)
-            print t.__dict__
+            print(dir(t))
+            print(t.__dict__)
             raise
         if t.result == TEST_NOTRUN:
             count[NOTRUN] += 1
@@ -434,7 +435,7 @@ def printresults(tests, opts, file=None):
             count[WARN] += 1
         elif t.result == TEST_PASS:
             count[PASS] += 1
-    print >> file, "*"*50 
+    print("*"*50, file=file)
     for t in tests:
         if t.result == TEST_NOTRUN:
             continue
@@ -448,16 +449,16 @@ def printresults(tests, opts, file=None):
             continue
         if (not opts.showfail) and t.result == TEST_FAIL:
             continue
-        print >> file, t.display(0,0)
-    print >> file, "*"*50
+        print(t.display(0,0), file=file)
+    print("*"*50, file=file)
     if count[NOTRUN]:
-        print >> file, "Tests interrupted! Only %i tests run" % \
-              sum(count[SKIP:])
+        print("Tests interrupted! Only %i tests run" % \
+              sum(count[SKIP:]), file=file)
     else:
-        print >> file, "Command line asked for %i of %i tests" % \
-              (sum(count[SKIP:]), len(tests))
-    print >> file, "Of those: %i Skipped, %i Failed, %i Warned, %i Passed" % \
-          (count[SKIP], count[FAIL], count[WARN], count[PASS])
+        print("Command line asked for %i of %i tests" % \
+              (sum(count[SKIP:]), len(tests)), file=file)
+    print("Of those: %i Skipped, %i Failed, %i Warned, %i Passed" % \
+          (count[SKIP], count[FAIL], count[WARN], count[PASS]), file=file)
     return count[FAIL]
 
 def xml_printresults(tests, file_name, suite='all'):
diff --git a/nfs4.1/testserver.py b/nfs4.1/testserver.py
index 9c2133e..70b4f62 100755
--- a/nfs4.1/testserver.py
+++ b/nfs4.1/testserver.py
@@ -28,7 +28,7 @@
 import use_local # HACK so don't have to rebuild constantly
 import sys
 if sys.hexversion < 0x02050000:
-    print "Requires python 2.5 or higher"
+    print("Requires python 2.5 or higher")
     sys.exit(1)
 import os
 
@@ -196,16 +196,16 @@ def printflags(list):
     command_names = [s.lower()[3:].replace('_', '') \
                      for s in nfs_opnum4.values()]
     list.sort()
-    # First print command names
+    # First print(command names)
     print
     for s in list:
         if s in command_names:
-            print s
+            print(s)
     # Then everything else
     print
     for s in list:
         if s not in command_names:
-            print s
+            print(s)
     
 def main():
     p = OptionParser("%prog SERVER:/PATH [options] flags|testcodes\n"
@@ -229,14 +229,14 @@ def main():
         codes = cdict.keys()
         codes.sort()
         for c in codes:
-            print c
+            print(c)
         sys.exit(0)
 
     if opt.showcodesflags:
         codes = cdict.keys()
         codes.sort()
         for c in codes:
-            print c, "FLAGS:", ', '.join(cdict[c].flags_list)
+            print(c, "FLAGS:", ', '.join(cdict[c].flags_list))
         sys.exit(0)
 
     # Grab server info and set defaults
@@ -257,14 +257,14 @@ def main():
     for attr in dir(opt):
         if attr.startswith('use') and attr != "usefh":
             path = getattr(opt, attr)
-            #print attr, path
+            #print(attr, path)
             if path is None:
                 path = opt.path + ['tree', attr[3:]]
             else:
                 # FIXME - have funct that checks path validity
                 if path[0] != '/':
                     p.error("Need to use absolute path for --%s" % attr)
-                # print path
+                # print(path)
                 if path[-1] == '/' and attr != 'usedir':
                     p.error("Can't use dir for --%s" %attr)
                 try:
@@ -316,21 +316,21 @@ def main():
     # Place tests in desired order
     tests.sort() # FIXME - add options for random sort
 
-    # Run the tests and save/print results
+    # Run the tests and save/print(results)
     try:
         env = environment.Environment(opt)
         env.init()
     except socket.gaierror, e:
         if e.args[0] == -2:
-            print "Unknown server '%s'" % opt.server
-        print sys.exc_info()[1]
+            print("Unknown server '%s'" % opt.server)
+        print(sys.exc_info()[1])
         sys.exit(1)
     except Exception, e:
-        print "Initialization failed, no tests run."
+        print("Initialization failed, no tests run.")
         if not opt.maketree:
-            print "Perhaps you need to use the --maketree option"
+            print("Perhaps you need to use the --maketree option")
         raise
-        print sys.exc_info()[1]
+        print(sys.exc_info()[1])
         sys.exit(1)
     if opt.outfile is not None:
         fd = file(opt.outfile, 'w')
@@ -350,7 +350,7 @@ def main():
         fail = True
     testmod.printresults(tests, opt)
     if fail:
-        print "\nWARNING: could not clean testdir due to:\n%s\n" % str(e)
+        print("\nWARNING: could not clean testdir due to:\n%s\n" % str(e))
 
     if opt.xmlout is not None:
         testmod.xml_printresults(tests, opt.xmlout)
diff --git a/rpc/rpc.py b/rpc/rpc.py
index 1a3ca38..e06dbbf 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -878,8 +878,8 @@ class ConnectionHandler(object):
     def listen(self, pipe, xid):
         # STUB - should be overwritten by subclass
         header, data = pipe.listen(xid)
-        print "HEADER", header
-        print "DATA", repr(data)
+        print("HEADER", header)
+        print("DATA", repr(data))
 
 #################################################
 
diff --git a/setup.py b/setup.py
index a032afe..ace0ab5 100755
--- a/setup.py
+++ b/setup.py
@@ -1,5 +1,7 @@
 #!/usr/bin/env python
 
+from __future__ import print_function
+
 from distutils.core import setup
 
 import sys
@@ -19,7 +21,7 @@ def setup(*args, **kwargs):
     cwd = os.getcwd()
     command = " ".join(sys.argv)
     for dir in DIRS:
-        print "\n\nMoving to %s" % dir 
+        print("\n\nMoving to %s" % dir )
         os.chdir(join(cwd, dir))
         os.system("python %s" % command)
     os.chdir(cwd)
diff --git a/showresults.py b/showresults.py
index b843a5f..78b4690 100755
--- a/showresults.py
+++ b/showresults.py
@@ -8,6 +8,7 @@
 #                    Information Technology Integration
 #
 
+from __future__ import print_function
 
 # Allow to be run stright from package root
 if  __name__ == "__main__":
diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
index 4eb5b16..6353835 100755
--- a/xdr/xdrgen.py
+++ b/xdr/xdrgen.py
@@ -300,7 +300,7 @@ def t_linecomment(t):
     t.lexer.lineno += 1
 
 def t_error(t):
-    print "Illegal character %s at %d type %s" % (repr(t.value[0]), t.lexer.lineno, t.type)
+    print("Illegal character %s at %d type %s" % (repr(t.value[0]), t.lexer.lineno, t.type))
     t.lexer.skip(1)
     
 # Build the lexer
@@ -371,7 +371,7 @@ def p_optional_value(t):
     if msg:
         global error_occurred
         error_occurred = True
-        print "ERROR - %s near line %i" % (msg, t.lineno(1))
+        print("ERROR - %s near line %i" % (msg, t.lineno(1)))
 
 def p_type_def_1(t):
     '''type_def : TYPEDEF declaration SEMI'''
@@ -382,7 +382,7 @@ def p_type_def_1(t):
     if d.type == 'void':
         global error_occurred
         error_occurred = True
-        print "ERROR - can't use void in typedef at line %i" % lineno
+        print("ERROR - can't use void in typedef at line %i" % lineno)
         return
     d.lineno = lineno
     if id_unique(d.id, d.type, lineno):
@@ -560,11 +560,11 @@ def p_enum_constant(t):
             # We have a name instead of a constant, make sure it is defined
             if value not in name_dict:
                 error_occurred = True
-                print "ERROR - can't derefence %s at line %s" % (value, lineno)
+                print("ERROR - can't derefence %s at line %s" % (value, lineno))
             elif not isinstance(name_dict[value], const_info):
                 error_occurred = True
-                print "ERROR - reference to %s at line %s is not a constant" %\
-                      (value, lineno)
+                print("ERROR - reference to %s at line %s is not a constant" %\
+                      (value, lineno))
             else:
                 info.positive = name_dict[value].positive
         t[0] = [info]
@@ -586,9 +586,9 @@ def p_error(t):
     global error_occurred
     error_occurred = True
     if t:
-        print "Syntax error at '%s' (lineno %d)" % (t.value, t.lineno)
+        print("Syntax error at '%s' (lineno %d)" % (t.value, t.lineno))
     else:
-        print "Syntax error: unexpectedly hit EOF"
+        print("Syntax error: unexpectedly hit EOF")
 
 #
 # RPC specific routines follow
@@ -596,7 +596,7 @@ def p_error(t):
 
 def p_program_def(t):
     '''program_def : PROGRAM ID LBRACE version_def version_def_list RBRACE EQUALS constant SEMI'''
-    print "Ignoring program %s = %s" % (t[2], t[8])
+    print("Ignoring program %s = %s" % (t[2], t[8]))
     global name_dict
     id = t[2]
     value = t[8]
@@ -666,8 +666,8 @@ def id_unique(id, name, lineno):
     if id in name_dict:
         global error_occurred
         error_occurred = True
-        print "ERROR - %s definition %s at line %s conflicts with %s" % \
-              (name, id, lineno, name_dict[id])
+        print("ERROR - %s definition %s at line %s conflicts with %s" % \
+              (name, id, lineno, name_dict[id]))
         return False
     else:
         return True
@@ -1391,7 +1391,7 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
     global use_filters, allow_attr_passthrough
     use_filters = filters
     allow_attr_passthrough = pass_attrs
-    print "Input file is", infile
+    print("Input file is", infile)
 
     # Create output file names (without .py)
     global constants_file, types_file, packer_file
@@ -1399,8 +1399,8 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
     constants_file = name_base + "_const"
     types_file = name_base + "_type"
     packer_file = name_base + "_pack"
-    print "Will use output files %s.py, %s.py, and %s.py" % \
-          (constants_file, types_file, packer_file)
+    print("Will use output files %s.py, %s.py, and %s.py" % \
+          (constants_file, types_file, packer_file))
 
     # Parse the input data with yacc
     global name_dict
@@ -1414,7 +1414,7 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
 
     if error_occurred:
         print
-        print "Error occurred, did not write output files"
+        print("Error occurred, did not write output files")
         return 1
 
     comment_string = "# Generated by rpcgen.py from %s on %s\n" % \
@@ -1433,7 +1433,7 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
     type_list = name_dict.values()
     type_list.sort()
     for value in type_list:
-        #print value
+        #print(value)
         output = value.const_output()
         if output is not None:
             #const_fd.write("# **** %s ****\n" % value.id)
@@ -1465,7 +1465,7 @@ def run(infile, filters=True, pass_attrs=True, debug=False):
 #
 if __name__ == "__main__":
     if len(sys.argv) < 2:
-        print "Usage: %s <filename>" % sys.argv[0]
+        print("Usage: %s <filename>" % sys.argv[0])
         sys.exit(1)
 
     run(sys.argv[1])
-- 
2.17.1

