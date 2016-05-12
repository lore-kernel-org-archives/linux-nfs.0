Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19936 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbcELGQl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2016 02:16:41 -0400
Date: Thu, 12 May 2016 09:11:53 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: re: NFSv4.x: Enforce the ca_maxresponsesize_cached on the back
 channel
Message-ID: <20160512061113.GA20157@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond Myklebust,

The patch 80f9642724af: "NFSv4.x: Enforce the
ca_maxresponsesize_cached on the back channel" from Jan 23, 2016,
leads to the following static checker warning:

  fs/nfs/callback_proc.c:540 nfs4_callback_sequence()
  warn: inconsistent returns 'spin_lock:&tbl->slot_tbl_lock'.
    Locked on:   line 504
    Unlocked on: line 540

fs/nfs/callback_proc.c
   490          res->csr_highestslotid = tbl->server_highest_slotid;
   491          res->csr_target_highestslotid = tbl->target_highest_slotid;
   492  
   493          status = validate_seqid(tbl, slot, args);
   494          if (status)
   495                  goto out_unlock;
   496          if (!nfs4_try_to_lock_slot(tbl, slot)) {
   497                  status = htonl(NFS4ERR_DELAY);
   498                  goto out_unlock;
                        ^^^^^^^^^^^^^^^
   499          }
   500          cps->slot = slot;
   501  
   502          /* The ca_maxresponsesize_cached is 0 with no DRC */
   503          if (args->csa_cachethis != 0)
   504                  return htonl(NFS4ERR_REP_TOO_BIG_TO_CACHE);

This should also unlock and possibly do other unwinding?

   505  
   506          /*
   507           * Check for pending referring calls.  If a match is found, a
   508           * related callback was received before the response to the original
   509           * call.
   510           */
   511          if (referring_call_exists(clp, args->csa_nrclists, args->csa_rclists)) {
   512                  status = htonl(NFS4ERR_DELAY);
   513                  goto out_unlock;
   514          }

regards,
dan carpenter
