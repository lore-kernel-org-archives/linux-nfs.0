Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp3.stanford.edu ([171.67.219.83]:58189 "EHLO
	smtp.stanford.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753447AbbBKVsI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 16:48:08 -0500
From: David Ramos <daramos@stanford.edu>
Content-Type: text/plain; charset=utf-8
Subject: Possible NFS 4.1 client vulnerability: uninitialized/garbage kfree() in decode_cb_sequence_args()
Date: Wed, 11 Feb 2015 13:39:22 -0800
Message-Id: <572E44F4-FA95-4D53-949F-B553974F2F2B@stanford.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Our UC-KLEE tool found a kfree() of an uninitialized pointer in decode_cb_sequence_args (fs/nfs/callback_xdr.c) that may be remotely exploitable. The bug affects Linux kernel 3.16.3, but it appears to date back to commit 4aece6a19cf7f474f15eb861ba74db4479884ce3 (4/1/2009), which first implemented the CB_SEQUENCE operation from NFS 4.1.

Here is some of the relevant code:
 458        if (args->csa_nrclists) {
 459                args->csa_rclists = kmalloc_array(args->csa_nrclists,
 460                                                  sizeof(*args->csa_rclists),
 461                                                  GFP_KERNEL);
 ...
 465                for (i = 0; i < args->csa_nrclists; i++) {
 466                        status = decode_rc_list(xdr, &args->csa_rclists[i]);
 467                        if (status)
 468                                goto out_free;
 469                }
 470        }
 …
 487out_free:
 488        for (i = 0; i < args->csa_nrclists; i++)
 489                kfree(args->csa_rclists[i].rcl_refcalls);

If a call to decode_rc_list() on line 466 returns non-zero during iteration ‘i', the kfree() call at line 489 will attempt to free uninitialized (heap garbage) pointers for all indices in [i, args->csa_nrclists).

I’m not familiar enough with the NFS internals to understand whether an attacker can cause decode_rc_list() to fail (i.e., by causing read_buf() to fail), but it seems plausible?

Thanks,
-David



