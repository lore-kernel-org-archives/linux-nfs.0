Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbbE0SBe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2015 14:01:34 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t4RI1Xej017435
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 14:01:34 -0400
Received: from bcodding-csb.redhat.com (vpn-55-212.rdu2.redhat.com [10.10.55.212])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t4RI1Xv7011285
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 14:01:33 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs 3/3] itm: add a handler that truncates READDIR response page data
Date: Wed, 27 May 2015 14:01:32 -0400
Message-Id: <e9251ca3f9a403311a54bc8dad12d794965c77c0.1432749206.git.bcodding@redhat.com>
In-Reply-To: <cover.1432749206.git.bcodding@redhat.com>
References: <cover.1432749206.git.bcodding@redhat.com>
In-Reply-To: <cover.1432749206.git.bcodding@redhat.com>
References: <cover.1432749206.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 itm/handlers/readdir_reply_nopages.py |   86 +++++++++++++++++++++++++++++++++
 1 files changed, 86 insertions(+), 0 deletions(-)
 create mode 100644 itm/handlers/readdir_reply_nopages.py

diff --git a/itm/handlers/readdir_reply_nopages.py b/itm/handlers/readdir_reply_nopages.py
new file mode 100644
index 0000000..e5dd91e
--- /dev/null
+++ b/itm/handlers/readdir_reply_nopages.py
@@ -0,0 +1,86 @@
+from rpc_const import *
+from xdrdef.nfs4_const import *
+from xdrdef.nfs4_type import *
+from xdrdef.nfs3_const import *
+from xdrdef.nfs3_type import *
+from xdrdef.nfs3_pack import NFS3Packer, NFS3Unpacker
+from nfs4commoncode import encode_status_by_name
+from itm.handlers import BaseHandler
+
+import itm
+import nfs4lib
+
+"""
+   This handler modifies the response body for a v4 READDIR call
+   or v3 READDIRPLUS call such that there are no pages of data in
+   the response.
+
+   https://bugzilla.redhat.com/show_bug.cgi?id=1182830
+   http://marc.info/?l=linux-nfs&m=142964061807798&w=2
+   ce85cfb NFS: Don't attempt to decode missing directory entries
+"""
+
+class Handler(BaseHandler):
+
+	def will_handle(self, cb_info):
+
+		# setup for v4:
+		if hasattr(cb_info, "v4_res"):
+			res = cb_info.v4_res;
+			my_ops = filter(lambda x: x.resop == OP_READDIR, res.resarray)
+			if not my_ops:
+				return 0;
+
+			# save the resop for handle()
+			self.my_resop = my_ops[0]
+			return 1;
+
+		# setup for v3:
+		msg = cb_info.rpc_msg
+		if msg.body.mtype == REPLY and \
+			msg.body.cbody.vers == 3 and \
+			msg.body.cbody.proc == NFSPROC3_READDIRPLUS:
+
+			unpacker = NFS3Unpacker(cb_info.rpc_msg_data)
+			self.my_resop = unpacker.unpack_READDIRPLUS3res()
+
+			return 1;
+
+		return 0;
+
+	def handle(self, cb_info):
+		print "readdir is returning no pages"
+
+		msg = cb_info.rpc_msg
+
+		if msg.body.cbody.vers == 4:
+			# remove whatever results were being returned so that we have a
+			# predictable length:
+			self.my_resop.opreaddir.resok4.reply = dirlist4([], eof=0)
+
+			p = nfs4lib.FancyNFS4Packer()
+			p.pack_COMPOUND4res(cb_info.v4_res)
+			buf = p.get_buffer()
+
+			# chop off the page data:
+			cb_info.rpc_msg_data = buf[:-8]
+			#itm.dump_data(cb_info.rpc_msg_data)
+			cb_info.encode_RPC()
+			return 1
+
+		elif msg.body.cbody.vers == 3:
+			# remove whatever results were being returned so that we have a
+			# predictable length:
+			self.my_resop.resok.reply = dirlistplus3([], eof=0)
+
+			p = NFS3Packer()
+			p.pack_READDIRPLUS3res(self.my_resop)
+			buf = p.get_buffer()
+
+			# chop off the page data:
+			cb_info.rpc_msg_data = buf[:-8]
+			#itm.dump_data(cb_info.rpc_msg_data)
+			cb_info.encode_RPC()
+			return 1
+
+		return 0
-- 
1.7.1

