Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:63780 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbaBZT3x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Feb 2014 14:29:53 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so1348106pdi.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 Feb 2014 11:29:52 -0800 (PST)
Message-ID: <1393442989.5090.4.camel@leira.trondhjem.org>
Subject: Re: Oops in nfs41_assign_slot in Linux 3.13.4
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: 734268@bugs.debian.org, Arthur de Jong <adejong@debian.org>,
        linux-nfs@vger.kernel.org
Date: Wed, 26 Feb 2014 11:29:49 -0800
In-Reply-To: <1393376280.14067.34.camel@deadeye.wl.decadent.org.uk>
References: <1388922864.10916.7.camel@sorbet.thuis.net>
	 <1393361101.5000.26.camel@sorbet.thuis.net>
	 <1393376280.14067.34.camel@deadeye.wl.decadent.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

On Wed, 2014-02-26 at 00:58 +0000, Ben Hutchings wrote:
> Trond, Arthur seems to be hitting a similar bug to
> <https://bugzilla.redhat.com/show_bug.cgi?id=1050206>, and it's still
> occurring in 3.13.4 even though that has the two fixes you posted there.
> The full bug report, with screenshots of the oopses, is at
> <https://bugs.debian.org/734268>.
> 

I believe I've found another corruptor of that same list. Do Arthur's
tests perhaps touch on file locking? If so, then the following patch may
help...

Cheers
  Trond

8<----------------------------------------------------------------------
>From 3db0ebd8e7e67d9ee96f623e7d1dcdc35fccea7f Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 26 Feb 2014 11:19:14 -0800
Subject: [PATCH] NFSv4: Fix another nfs4_sequence corruptor

nfs4_release_lockowner needs to set the rpc_message reply to point to
the nfs4_sequence_res in order to avoid another Oopsable situation
in nfs41_assign_slot.

Fixes: fbd4bfd1d9d21 (NFS: Add nfs4_sequence calls for RELEASE_LOCKOWNER)
Cc: stable@vger.kernel.org # 3.12+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2da6a698b8f7..d3b829f7c509 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5895,6 +5895,7 @@ static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_st
 	data->args.lock_owner.s_dev = server->s_dev;
 
 	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
 	return 0;
 }
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


