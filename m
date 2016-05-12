Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:34198 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbcELTTF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2016 15:19:05 -0400
Received: by mail-ig0-f196.google.com with SMTP id kj7so387877igb.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 12:19:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160512061113.GA20157@mwanda>
References: <20160512061113.GA20157@mwanda>
Date: Thu, 12 May 2016 15:19:03 -0400
Message-ID: <CAN-5tyHXmTGBM32MqWmdxeQng_9KiTbwhePA79vwzUxVra9uww@mail.gmail.com>
Subject: Re: NFSv4.x: Enforce the ca_maxresponsesize_cached on the back channel
From: Olga Kornievskaia <aglo@umich.edu>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yep that leads to the kernel oops. I have posted a patch. Hopefully
Trond will approve it.

On Thu, May 12, 2016 at 2:11 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Hello Trond Myklebust,
>
> The patch 80f9642724af: "NFSv4.x: Enforce the
> ca_maxresponsesize_cached on the back channel" from Jan 23, 2016,
> leads to the following static checker warning:
>
>   fs/nfs/callback_proc.c:540 nfs4_callback_sequence()
>   warn: inconsistent returns 'spin_lock:&tbl->slot_tbl_lock'.
>     Locked on:   line 504
>     Unlocked on: line 540
>
> fs/nfs/callback_proc.c
>    490          res->csr_highestslotid = tbl->server_highest_slotid;
>    491          res->csr_target_highestslotid = tbl->target_highest_slotid;
>    492
>    493          status = validate_seqid(tbl, slot, args);
>    494          if (status)
>    495                  goto out_unlock;
>    496          if (!nfs4_try_to_lock_slot(tbl, slot)) {
>    497                  status = htonl(NFS4ERR_DELAY);
>    498                  goto out_unlock;
>                         ^^^^^^^^^^^^^^^
>    499          }
>    500          cps->slot = slot;
>    501
>    502          /* The ca_maxresponsesize_cached is 0 with no DRC */
>    503          if (args->csa_cachethis != 0)
>    504                  return htonl(NFS4ERR_REP_TOO_BIG_TO_CACHE);
>
> This should also unlock and possibly do other unwinding?
>
>    505
>    506          /*
>    507           * Check for pending referring calls.  If a match is found, a
>    508           * related callback was received before the response to the original
>    509           * call.
>    510           */
>    511          if (referring_call_exists(clp, args->csa_nrclists, args->csa_rclists)) {
>    512                  status = htonl(NFS4ERR_DELAY);
>    513                  goto out_unlock;
>    514          }
>
> regards,
> dan carpenter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
