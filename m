Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbbE0SBd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2015 14:01:33 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t4RI1XRb010823
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 14:01:33 -0400
Received: from bcodding-csb.redhat.com (vpn-55-212.rdu2.redhat.com [10.10.55.212])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t4RI1Xdx003246
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 14:01:33 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs 2/3] Add a tool for modification of NFS network traffic: itm
Date: Wed, 27 May 2015 14:01:31 -0400
Message-Id: <15d7a7b50446ed00ed2f602ee3071939c368a102.1432749206.git.bcodding@redhat.com>
In-Reply-To: <cover.1432749206.git.bcodding@redhat.com>
References: <cover.1432749206.git.bcodding@redhat.com>
In-Reply-To: <cover.1432749206.git.bcodding@redhat.com>
References: <cover.1432749206.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a framework to allow the inspection and modification of NFS network
traffic between an existing server and client, provided one of them is able
to use netfilter's libnfqueue.  This essentially linux-only tool is similar
to nfs-proxy in that it can be used to inject protocol errors and other
behaviors, however it is more convenient to use on linux as it can quickly
be inserted or removed from existing server-client pairs.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 itm/README               |   26 +++++
 itm/handlers.py          |    9 ++
 itm/handlers/default.py  |   19 ++++
 itm/handlers/example.py  |   14 +++
 itm/itm.py               |  230 ++++++++++++++++++++++++++++++++++++++++++++++
 itm/run_itm.sh           |   41 ++++++++
 itm/use_local.py         |   14 +++
 7 files changed, 353 insertions(+), 0 deletions(-)
 create mode 100644 itm/README
 create mode 100644 itm/__init__.py
 create mode 100644 itm/handlers.py
 create mode 100644 itm/handlers/__init__.py
 create mode 100644 itm/handlers/default.py
 create mode 100644 itm/handlers/example.py
 create mode 100755 itm/itm.py
 create mode 100755 itm/run_itm.sh
 create mode 100644 itm/use_local.py

diff --git a/itm/README b/itm/README
new file mode 100644
index 0000000..5bd435e
--- /dev/null
+++ b/itm/README
@@ -0,0 +1,26 @@
+PyNFS ITM - In-the-Middle
+
+This tool uses bits of the main pynfs encoding/decoding functionality to
+allow the inspection and modification of NFS network traffic between clients
+and servers.  More than a few bugs have been difficult to reproduce from
+above the filesystem, and some bugs require access to specialized servers
+that behave in strange ways.  This tool may allow a shorter path to problem
+reproduction when the on-wire behavior is known be reproduced by  enabling
+the quick injection and then removal of behaviors written into handlers.
+
+This tool relies on libnetfilter_queue to forward packets from a Linux
+client or server's netfilter to userspace to accept or modify the payload.
+
+Requirements:
+ nfqueue-bindings
+	https://www.wzdftpd.net/redmine/projects/nfqueue-bindings/wiki
+ python-dpkt
+
+Usage:
+First, edit itm/run_itm.sh to configure either the client or server's
+hostname.  If running on a client, set the server's name; if on a server,
+set the client's hostname.
+
+./itm/run_itm.sh [name of handler] 
+
+Handlers can be found/created in itm/handlers/
diff --git a/itm/__init__.py b/itm/__init__.py
new file mode 100644
index 0000000..e69de29
diff --git a/itm/handlers.py b/itm/handlers.py
new file mode 100644
index 0000000..8fba14a
--- /dev/null
+++ b/itm/handlers.py
@@ -0,0 +1,9 @@
+class BaseHandler(object):
+	def __init__(self):
+		pass
+
+	def will_handle(self, cb_info):
+		return 0;
+
+	def handle(self, cb_info):
+		return 0;
diff --git a/itm/handlers/__init__.py b/itm/handlers/__init__.py
new file mode 100644
index 0000000..e69de29
diff --git a/itm/handlers/default.py b/itm/handlers/default.py
new file mode 100644
index 0000000..89d828a
--- /dev/null
+++ b/itm/handlers/default.py
@@ -0,0 +1,19 @@
+import itm
+from itm.handlers import BaseHandler
+
+class Handler(BaseHandler):
+	''' this default handler only prints out information about
+		rpc message '''
+	def __init__(self):
+		print "init default itm.handler"
+
+	def will_handle(self, cb_info):
+		# turn me on!
+		return 0
+
+	def handle(self, cb_info):
+		cb_info.dump_IP()
+		#cb_info.dump_RPC()
+		#cb_info.dump_NFS()
+		#cb_info.dump_data()
+		return 0
diff --git a/itm/handlers/example.py b/itm/handlers/example.py
new file mode 100644
index 0000000..7395493
--- /dev/null
+++ b/itm/handlers/example.py
@@ -0,0 +1,14 @@
+from itm.handlers import BaseHandler
+
+class Handler(BaseHandler):
+	def will_handle(self, cb_info):
+		# implement stateful setup or conditions here
+		# return 1 if you want to handle this record
+		return 0
+
+	def handle(self, cb_info):
+		# modify the payload here
+		# return 1 to submit the modified payload
+		return 0
+		
+
diff --git a/itm/itm.py b/itm/itm.py
new file mode 100755
index 0000000..a07d2b7
--- /dev/null
+++ b/itm/itm.py
@@ -0,0 +1,230 @@
+#!/usr/bin/python
+
+# need root privileges
+import struct
+import sys
+import time
+import argparse
+import use_local
+import rpc
+import rpc_pack
+import rpclib
+import nfs4lib
+
+from rpc_const import *
+from rpc_type import *
+from socket import AF_INET, AF_INET6, inet_ntoa
+import nfqueue
+
+sys.path.append('dpkt-1.6')
+from dpkt import ip, tcp
+
+count = 0
+xid_lookup = {}
+
+# helper to dump out the bits:
+def dump_data(data):
+	try:
+		print "length %d" % len(data),
+		for i in range(0, len(data), 4):
+			if i % 16 == 0:
+				print "\n{0:04x}: ".format(i),
+			print "{0:02x} {1:02x} {2:02x} {3:02x}".format(
+				*struct.unpack_from("BBBB", data, i)), 
+		print "\n"
+	except Exception, e:
+		print "failed to dump_data, %s" % e
+
+class CB_Info(object):
+	def __init__(self):
+		pass
+
+	def dump_data(self):
+		itm.dump_data(self.data)
+
+	def dump_IP(self):
+		pkt = self.pkt
+		print "proto %s src: %s:%s    dst %s:%s " % \
+			(pkt.p,inet_ntoa(pkt.src), pkt.tcp.sport, \
+			inet_ntoa(pkt.dst),pkt.tcp.dport)
+
+		print "ip len is %d" % self.pkt.len
+		print "tcp len is %d" % len(self.pkt.tcp.data)
+
+	def dump_RPC(self):
+		msg = self.rpc_msg
+		msg_data = self.rpc_msg_data
+		print "msg = %s" % str(msg)
+		#print "data = %s" % msg_data
+		print "xid = %s" % msg.xid
+		print "mtype = %s" % msg_type[msg.body.mtype]
+		print "rpcvers = %s" % msg.body.cbody.rpcvers
+		print "prog = %s" % msg.body.cbody.prog
+		print "vers = %s" % msg.body.cbody.vers
+		print "proc = %s" % msg.body.cbody.proc
+		#print dir(msg)
+
+	def dump_NFS(self):
+		if hasattr(self, "v4_args"):
+			print repr(self.v4_args)
+
+		if hasattr(self, "v4_res"):
+			print repr(self.v4_res)
+
+	# a little help for the v4 handlers so they don't all have to do this:
+	def decode_proc1_v4(self, data):
+		unpacker = nfs4lib.FancyNFS4Unpacker(data)
+		if self.rpc_msg.mtype == CALL:
+			self.v4_args = unpacker.unpack_COMPOUND4args()
+		elif self.rpc_msg.mtype == REPLY:
+			self.v4_res = unpacker.unpack_COMPOUND4res()
+		unpacker.done()
+
+	def decode_RPC_CALL(self):
+		msg = self.rpc_msg
+		msg_data = self.rpc_msg_data
+		self.sec = sec = rpc.security.instances()[msg.body.cred.flavor]
+		credinfo = sec.check_auth(msg, msg_data)
+		msg_data = credinfo.sec.unsecure_data(msg.body.cred, msg_data)
+		self.rpc_msg_data = msg_data
+
+		global xid_lookup
+		xid_lookup[msg.xid] = self
+
+		# do a bit of extra decoding for COMPOUND
+		# should do this for every record or let the handlers decide?
+		method = getattr(self, 'decode_proc%i_v%i' % (msg.proc, msg.vers), None)
+		if method is not None:
+			method(msg_data)
+
+	def decode_RPC_REPLY(self):
+		global xid_lookup
+		try:
+			self.rpc_call = xid_lookup.pop(self.rpc_msg.xid)
+		except:
+			raise KeyError("Missing RPC CALL for xid %d" % self.rpc_msg.xid)
+
+		self.rpc_msg.body.cbody = cbody = self.rpc_call.rpc_msg.body.cbody
+
+		# do a bit of extra decoding for COMPOUND
+		method = getattr(self, 'decode_proc%i_v%i' % (cbody.proc, cbody.vers), None)
+		if method is not None:
+			method(self.rpc_msg_data)
+
+	def decode_RPC(self):
+		# TODO: handle frags (how?)
+		buf = self.pkt.tcp.data
+		packetlen = struct.unpack('>L', buf[0:4])[0]
+		last = 0x80000000L & packetlen
+		packetlen &= 0x7fffffffL
+		packetlen += 4 # Include size of record mark
+		if len(buf) != packetlen:
+			raise NotImplementedError("Can't do frags in-stream (yet)")
+
+		# move past our RPC frag header:
+		record = buf[4:]
+		p = rpc.FancyRPCUnpacker(record)
+		self.rpc_msg = p.unpack_rpc_msg() # RPC header
+		self.rpc_msg_data = record[p.get_position():] # RPC payload
+		# Remember length of the header
+		self.rpc_msg.length = p.get_position()
+		getattr(self, "decode_RPC_" + msg_type[self.rpc_msg.body.mtype])()
+
+	def encode_RPC(self):
+		p = rpc.FancyRPCPacker()
+		p.pack_rpc_msg(self.rpc_msg)
+		header = p.get_buffer()
+		record = header + self.rpc_msg_data
+
+		## TODO: handle frags..
+		frag_hdr = 0x80000000L | len(record)
+		self.pkt.tcp.data = struct.pack('>L', frag_hdr) + record
+		self.pkt.tcp.sum = 0
+		self.pkt.sum = 0
+		self.pkt.len = len(self.pkt)
+		self.data = self.pkt.pack()
+
+def cb(payload):
+	global args, count
+	count += 1
+
+	cb_info = CB_Info()
+	cb_info.instance = count
+	cb_info.payload = payload
+	cb_info.data = payload.get_data()
+	cb_info.pkt = pkt = ip.IP(cb_info.data)
+
+	if pkt.p != ip.IP_PROTO_TCP or not pkt.tcp.flags & tcp.TH_PUSH:
+		# not TCP, not PUSH
+		payload.set_verdict(nfqueue.NF_ACCEPT)
+		return
+
+	try:
+		cb_info.decode_RPC()
+	except Exception, e:
+		print "Decoding error: %s, skipping." % e
+		payload.set_verdict(nfqueue.NF_ACCEPT)
+		return
+
+	for handler in handlers:
+		if handler['instance'].will_handle(cb_info):
+			print "%s handles" % handler['module'].__name__
+			if handler['instance'].handle(cb_info):
+				payload.set_verdict_modified(nfqueue.NF_ACCEPT,\
+					cb_info.data, len(cb_info.data))
+				return 0
+
+	payload.set_verdict(nfqueue.NF_ACCEPT)
+	sys.stdout.flush()
+	return 1
+
+def setup():
+	import os
+	import imp
+
+	global handlers
+
+	parser = argparse.ArgumentParser(description='NFS MITM using nfqueue')
+	parser.add_argument('handlers', metavar='h.py', type=str, nargs='*',
+		help="python script of injectable behavior")
+	args = parser.parse_args()
+
+	args.handlers.insert(0, "default")
+
+	handlers_paths = [ [ 'itm.handlers.' + s, os.path.dirname(os.path.realpath(__file__)) +
+		'/handlers/' + s + '.py'] for s in args.handlers ]
+
+	imp.load_source("itm.handlers", os.path.dirname(os.path.realpath(__file__))
+		+ "/handlers.py")
+	handlers = []
+	for h in handlers_paths:
+		try:
+			handler = { 'module':imp.load_source(*h) }
+			handler['class'] = getattr(handler['module'], 'Handler')
+			handler['instance'] = handler['class']()
+			handlers.append( handler )
+		except IOError, e:
+			print "No such handler %s" % h[1]
+
+def main():
+	setup()
+
+	q = nfqueue.queue()
+	print "setting callback"
+	q.set_callback(cb)
+	print "open"
+	q.fast_open(0, AF_INET)
+	q.set_queue_maxlen(50000)
+	print "trying to run"
+	try:
+		q.try_run()
+	except KeyboardInterrupt, e:
+		print "interrupted"
+	print "%d packets handled" % count
+	print "unbind"
+	q.unbind(AF_INET)
+	print "close"
+	q.close()
+
+if __name__ == "__main__":
+	main()
diff --git a/itm/run_itm.sh b/itm/run_itm.sh
new file mode 100755
index 0000000..b803dad
--- /dev/null
+++ b/itm/run_itm.sh
@@ -0,0 +1,41 @@
+#!/bin/bash
+
+# this is an example helper script to add/remove netfilter rules for
+# the pynfs in-the-middle utility.  You should send both directions of TCP
+# traffic to the NFQUEUE target so that the utility can keep track of NFS
+# objects per RPC XID.  The benefit of using this wrapper is that your 
+# nfqueue target netfilter rules can be quickly pulled out when/if
+# the itm.py utility stops.
+
+# Set only one of the two variables:
+
+# I am running this on the nfs server recieving connections from
+#CLIENT=rhel6
+
+# OR I am running this on the nfs client connecting to
+SERVER=rhel6
+
+IP="$(dig ${CLIENT:-${SERVER}} +search +short | tail -1)"
+
+iptables -I ${CLIENT:+INPUT}${SERVER:+OUTPUT} 1 -m tcp -p tcp --dport 2049 ${CLIENT:+-s}${SERVER:+-d} ${IP} -j NFQUEUE || RET1=$?
+iptables -I ${CLIENT:+OUTPUT}${SERVER:+INPUT} 1 -m tcp -p tcp --sport 2049 ${CLIENT:+-d}${SERVER:+-s} ${IP} -j NFQUEUE || RET2=$?
+
+if [[ $RET1 -ne 0 ]]; then
+	echo "iptables failed (are you root?)"
+	exit -1 
+fi
+
+if [[ $RET2 -ne 0 ]]; then
+	echo "second iptables failed.. pulling out the first rule.."
+	iptables -D ${CLIENT:+INPUT}${SERVER:+OUTPUT} 1
+	exit -1
+fi
+
+pushd $(dirname $0) > /dev/null
+python itm.py "$@"
+popd > /dev/null
+
+iptables -D OUTPUT 1
+iptables -D INPUT 1
+
+# vim: set tw=0 wm=0:
diff --git a/itm/use_local.py b/itm/use_local.py
new file mode 100644
index 0000000..bbbb472
--- /dev/null
+++ b/itm/use_local.py
@@ -0,0 +1,14 @@
+import sys
+import os
+from os.path import join, split
+cwd = os.path.dirname(os.path.realpath(__file__))
+if True or cwd not in sys.path:
+    head, tail = split(cwd)
+    dirs = [ join(head, "gssapi"),
+             join(head, "xdr"),
+             join(head, "ply"),
+             join(head, "rpc"),
+             join(head, "nfs4.1"),
+             cwd,
+             ]
+    sys.path[1:1] = dirs
-- 
1.7.1

