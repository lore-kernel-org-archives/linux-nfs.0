From: Steve Dickson <SteveD@redhat.com>
Subject: [NFS] [PATCH] Stop call_decode() from ignorning RPC header errrors
Date: Wed, 20 Aug 2003 13:34:52 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F43B13C.5010403@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070801080006030704060606"
Cc: linux-kernel <linux-kernel@vger.kernel.org>, acl-devel@bestbits.at
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------070801080006030704060606
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch stop call_decode() from ignoring errors
that are found while parsing the RPC header. I turns
out the nfs acls routines need these error codes to do
the right thing...

SteveD.

--------------070801080006030704060606
Content-Type: text/plain;
 name="linux-2.4.21-sunrpc-calldecode.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-sunrpc-calldecode.patch"

--- linux-2.4.21/net/sunrpc/clnt.c.diff	2003-08-18 11:11:22.000000000 -0400
+++ linux-2.4.21/net/sunrpc/clnt.c	2003-08-20 12:13:02.000000000 -0400
@@ -784,9 +784,16 @@ call_decode(struct rpc_task *task)
 				__FUNCTION__);
 
 	/* Verify the RPC header */
-	if (!(p = call_verify(task)))
+	if (!(p = call_verify(task))) {
+		/*
+		 * When call_verfiy sets tk_action to NULL (via task_exit)
+		 * a non-retry-able error has occurred (like the server
+		 * not supporting a particular procedure call).
+		 */
+		if (task->tk_action == NULL)
+			return;
 		goto out_retry;
-
+	}
 	/*
 	 * The following is an NFS-specific hack to cater for setuid
 	 * processes whose uid is mapped to nobody on the server.

--------------070801080006030704060606--
