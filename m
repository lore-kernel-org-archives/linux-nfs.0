Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:65348 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751495AbbIIP6j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2015 11:58:39 -0400
From: Andrew W Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Subject: Re: upgrade/downgrade race
References: <m2h9n3btno.fsf@discipline.rit.edu>
Date: Wed, 09 Sep 2015 11:58:38 -0400
In-Reply-To: <m2h9n3btno.fsf@discipline.rit.edu> (Andrew W. Elble's message of
	"Wed, 09 Sep 2015 09:37:31 -0400")
Message-ID: <m27fnza8k1.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Or, put into really half-baked (I've only spent an evening looking at
nfs client code) terms, isn't something like this required?

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 11fe5d7..15b8150 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1923,8 +1923,16 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 		renew_lease(data->o_res.server, data->timestamp);
 		if (!(data->o_res.rflags & NFS4_OPEN_RESULT_CONFIRM))
 			nfs_confirm_seqid(&data->owner->so_seqid, 0);
+
+		if (nfs4_stateid_is_newer(&data->state->open_stateid, &data->o_res.stateid) &&
+		    !can_open_cached(data->state, data->o_arg.fmode, data->o_arg.open_flags)) {
+		    rpc_restart_call_prepare(task);
+		    goto out;
+	        }
 	}
 	data->rpc_done = 1;
+out:
+	return;
 }
 
 static void nfs4_open_release(void *calldata)


-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
