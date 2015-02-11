Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:45074 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbbBKWmp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 17:42:45 -0500
Received: by iecat20 with SMTP id at20so7719426iec.12
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 14:42:45 -0800 (PST)
Message-ID: <1423694562.7169.12.camel@primarydata.com>
Subject: Re: Possible NFS 4.1 client vulnerability: uninitialized/garbage
 kfree() in decode_cb_sequence_args()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Ramos <daramos@stanford.edu>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Feb 2015 17:42:42 -0500
In-Reply-To: <572E44F4-FA95-4D53-949F-B553974F2F2B@stanford.edu>
References: <572E44F4-FA95-4D53-949F-B553974F2F2B@stanford.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

On Wed, 2015-02-11 at 13:39 -0800, David Ramos wrote:
> Hello,
> 
> Our UC-KLEE tool found a kfree() of an uninitialized pointer in decode_cb_sequence_args (fs/nfs/callback_xdr.c) that may be remotely exploitable. The bug affects Linux kernel 3.16.3, but it appears to date back to commit 4aece6a19cf7f474f15eb861ba74db4479884ce3 (4/1/2009), which first implemented the CB_SEQUENCE operation from NFS 4.1.
> 
> Here is some of the relevant code:
>  458        if (args->csa_nrclists) {
>  459                args->csa_rclists = kmalloc_array(args->csa_nrclists,
>  460                                                  sizeof(*args->csa_rclists),
>  461                                                  GFP_KERNEL);
>  ...
>  465                for (i = 0; i < args->csa_nrclists; i++) {
>  466                        status = decode_rc_list(xdr, &args->csa_rclists[i]);
>  467                        if (status)
>  468                                goto out_free;
>  469                }
>  470        }
>  …
>  487out_free:
>  488        for (i = 0; i < args->csa_nrclists; i++)
>  489                kfree(args->csa_rclists[i].rcl_refcalls);
> 
> If a call to decode_rc_list() on line 466 returns non-zero during iteration ‘i', the kfree() call at line 489 will attempt to free uninitialized (heap garbage) pointers for all indices in [i, args->csa_nrclists).
> 
> I’m not familiar enough with the NFS internals to understand whether an attacker can cause decode_rc_list() to fail (i.e., by causing read_buf() to fail), but it seems plausible?
> 

Thanks for reporting this!

I can't see this issue as being exploitable without a fair amount of
trouble because the above RPC request would be incoming on a TCP
connection that was initiated by the NFSv4.1 client. If someone can do
that level of spoofing, then they can cause all sorts of mischief for
the client.

How about the following fix?

Cheers
  Trond

8<------------------------------------------------------------
>From 5d4f299811799ec4731e27983939ea83186be939 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 11 Feb 2015 17:27:55 -0500
Subject: [PATCH] NFSv4.1: Fix a kfree() of uninitialised pointers in
 decode_cb_sequence_args

If the call to decode_rc_list() fails due to a memory allocation error,
then we need to truncate the array size to ensure that we only call
kfree() on those pointer that were allocated.

Reported-by: David Ramos <daramos@stanford.edu>
Fixes: 4aece6a19cf7f ("nfs41: cb_sequence xdr implementation")
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_xdr.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f4ccfe6521ec..02f8d09e119f 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -464,8 +464,10 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 
 		for (i = 0; i < args->csa_nrclists; i++) {
 			status = decode_rc_list(xdr, &args->csa_rclists[i]);
-			if (status)
+			if (status) {
+				args->csa_nrclists = i;
 				goto out_free;
+			}
 		}
 	}
 	status = 0;
-- 
2.1.0



