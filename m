Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f41.google.com ([209.85.213.41]:56086 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbaCAT5A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Mar 2014 14:57:00 -0500
Received: by mail-yh0-f41.google.com with SMTP id f73so2237377yha.0
        for <linux-nfs@vger.kernel.org>; Sat, 01 Mar 2014 11:57:00 -0800 (PST)
Message-ID: <1393703818.7434.4.camel@leira.trondhjem.org>
Subject: Re: Oops in nfs41_assign_slot in Linux 3.13.4
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: 734268@bugs.debian.org, Arthur de Jong <adejong@debian.org>,
        linux-nfs@vger.kernel.org,
        Charles Edward Lever <Chuck.Lever@oracle.com>
Date: Sat, 01 Mar 2014 13:56:58 -0600
In-Reply-To: <1393703218.7434.2.camel@leira.trondhjem.org>
References: <1388922864.10916.7.camel@sorbet.thuis.net>
	 <1393361101.5000.26.camel@sorbet.thuis.net>
	 <1393376280.14067.34.camel@deadeye.wl.decadent.org.uk>
	 <1393442989.5090.4.camel@leira.trondhjem.org>
	 <1393703218.7434.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-03-01 at 13:46 -0600, Trond Myklebust wrote:
> On Wed, 2014-02-26 at 11:29 -0800, Trond Myklebust wrote:
> > Hi Ben,
> > 
> > On Wed, 2014-02-26 at 00:58 +0000, Ben Hutchings wrote:
> > > Trond, Arthur seems to be hitting a similar bug to
> > > <https://bugzilla.redhat.com/show_bug.cgi?id=1050206>, and it's still
> > > occurring in 3.13.4 even though that has the two fixes you posted there.
> > > The full bug report, with screenshots of the oopses, is at
> > > <https://bugs.debian.org/734268>.
> > > 
> > 
> > I believe I've found another corruptor of that same list. Do Arthur's
> > tests perhaps touch on file locking? If so, then the following patch may
> > help...
> 
> Now that Connecthon is over, here is a patch that actually compiles.
> 

Sigh... Third time lucky...
8<---------------------------------------------------------------------
>From b7e63a1079b266866a732cf699d8c4d61391bbda Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 26 Feb 2014 11:19:14 -0800
Subject: [PATCH v3] NFSv4: Fix another nfs4_sequence corruptor

nfs4_release_lockowner needs to set the rpc_message reply to point to
the nfs4_sequence_res in order to avoid another Oopsable situation
in nfs41_assign_slot.

Fixes: fbd4bfd1d9d21 (NFS: Add nfs4_sequence calls for RELEASE_LOCKOWNER)
Cc: stable@vger.kernel.org # 3.12+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 10 +++++-----
 include/linux/nfs_xdr.h |  5 +++++
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2da6a698b8f7..44e088dc357c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5828,8 +5828,7 @@ struct nfs_release_lockowner_data {
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server;
 	struct nfs_release_lockowner_args args;
-	struct nfs4_sequence_args seq_args;
-	struct nfs4_sequence_res seq_res;
+	struct nfs_release_lockowner_res res;
 	unsigned long timestamp;
 };
 
@@ -5837,7 +5836,7 @@ static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata
 {
 	struct nfs_release_lockowner_data *data = calldata;
 	nfs40_setup_sequence(data->server,
-				&data->seq_args, &data->seq_res, task);
+				&data->args.seq_args, &data->res.seq_res, task);
 	data->timestamp = jiffies;
 }
 
@@ -5846,7 +5845,7 @@ static void nfs4_release_lockowner_done(struct rpc_task *task, void *calldata)
 	struct nfs_release_lockowner_data *data = calldata;
 	struct nfs_server *server = data->server;
 
-	nfs40_sequence_done(task, &data->seq_res);
+	nfs40_sequence_done(task, &data->res.seq_res);
 
 	switch (task->tk_status) {
 	case 0:
@@ -5887,7 +5886,6 @@ static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_st
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
 		return -ENOMEM;
-	nfs4_init_sequence(&data->seq_args, &data->seq_res, 0);
 	data->lsp = lsp;
 	data->server = server;
 	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
@@ -5895,6 +5893,8 @@ static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_st
 	data->args.lock_owner.s_dev = server->s_dev;
 
 	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
 	return 0;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b2fb167b2e6d..5624e4e2763c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -467,9 +467,14 @@ struct nfs_lockt_res {
 };
 
 struct nfs_release_lockowner_args {
+	struct nfs4_sequence_args	seq_args;
 	struct nfs_lowner	lock_owner;
 };
 
+struct nfs_release_lockowner_res {
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs4_delegreturnargs {
 	struct nfs4_sequence_args	seq_args;
 	const struct nfs_fh *fhandle;
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


