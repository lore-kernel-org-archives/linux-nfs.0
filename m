From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: Re: [PATCH] kNFSd - 3 of 6 - lockd fails to purge blocked
 NLM_LOCKs
Date: Mon, 08 Sep 2003 13:00:40 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1062993640.642141.5528.nullmailer@yamt.dyndns.org>
References: <E19unZ5-0004VF-00@notabene>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: marcelo.tosatti@cyclades.com.br, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wDDL-0006Np-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Sep 2003 21:01:20 -0700
Received: from fla1aau049.kng.mesh.ad.jp ([219.107.129.49] helo=yamt.dyndns.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19wDDL-0003Dd-7u
	for nfs@lists.sourceforge.net; Sun, 07 Sep 2003 21:01:19 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: Your message of "Thu, 04 Sep 2003 16:25:55 +1000"
	<E19unZ5-0004VF-00@notabene>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi,

>   Solution is to use the value in "call->a_host" for the
> nlm_rebind_host(), and to set "b_host" with the host value found via an
> nlmsvc_lookup_host().

because b_call.a_host != b_host now,
i guess that you should release both nlm_host like following patch.

(the latter part of the patch is for an unrelated bug,
f_count leak on GRANTED RES.)

YAMAMOTO Takashi


--- linux/fs/lockd/svclock.c.BACKUP	2003-09-05 21:10:04.000000000 +0900
+++ linux/fs/lockd/svclock.c	2003-09-05 21:09:50.000000000 +0900
@@ -271,6 +271,7 @@ nlmsvc_delete_block(struct nlm_block *bl
 	}
 
 	nlm_release_host(block->b_host);
+	nlm_release_host(block->b_call.a_host);
 	nlmclnt_freegrantargs(&block->b_call);
 	kfree(block);
 }
@@ -640,7 +641,6 @@ nlmsvc_grant_reply(struct svc_rqst *rqst
 		} else {
 			/* Lock is now held by client, or has been rejected.
 			 * In both cases, the block should be removed. */
-			file->f_count++;
 			up(&file->f_sema);
 			if (status == NLM_LCK_GRANTED)
 				nlmsvc_delete_block(block, 0);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
