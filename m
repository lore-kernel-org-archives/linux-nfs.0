From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 0/14] NFSv4.1 Server DRC rewrite Version 4
Date: Sun, 28 Jun 2009 19:01:04 +0300
Message-ID: <4A4793C0.5040903@panasas.com>
References: <> <1245872278-18743-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:6680
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753401AbZF1QBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jun 2009 12:01:03 -0400
In-Reply-To: <1245872278-18743-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andy,

I've merged this patchset onto the nfsd41 branch which
is now based on 2.6.31-rc1, replacing the respective patches
you sent previously.

Benny

On Jun. 24, 2009, 22:37 +0300, andros@netapp.com wrote:
> NFSv4.1 Server DRC rewrite Version 4
> 
> This patch set applies to linux-nfs.org/~bfields/linux, for-2.6.31 branch
> updated on 6-22-2009.
> 
> In response to bfield's comments I moved the DRC limit bug fixes to the front
> of the series, consolidated patches replacing the single slot clientid DRC
> into one patch and the replacement of the mulitple slot sequeqnce operation
> DRC into another single patch.
> 
> The NFSv4.1 DRC is changed from a page based cache to
> a buffer based cache. The logic for the single slot clientid cache has been
> separated from the session slot logic to handle the CREATE_SESSION call
> preceeded by a SEQUENCE and all the replay combinations therein.
> 
> The session DRC now caches encoded operations with the exception of the
> SEQUENCE operation which for a replay is encoded with the current slot and
> session values.  A review of message sizes indicates that a 512 byte buffer
> for the operations is adequate.
> 
> Not addressed is replacing the nfsd4_check_drc_limit() post-operation checking
> with a pre-operation processing estimate of the encoded per operation result
> 
> Testing:
> 4.1 mount: Connectathon and 4.1pynfs including the new create session replay
> tests.
> 4.0 mount; Connectathon.
> 
> 0001-nfsd41-use-globals-for-DRC-limits.patch
> 0002-nfsd41-change-from-page-to-memory-based-drc-limits.patch
> 0003-nfsd41-reclaim-DRC-memory-on-session-free.patch
> 0004-nfsd41-set-the-session-maximum-response-size-cached.patch
> 0005-nfsd41-remove-redundant-forechannel-max-requests-ch.patch
> 0006-nfsd41-change-check_slot_seqid-parameters.patch
> 0007-nfsd41-replace-create_session-DRC-with-xdr-structur.patch
> 0008-nfsd41-replace-page-based-DRC-with-buffer-based-DRC.patch
> 0009-nfsd41-rename-nfsd4_enc_uncached_replay.patch
> 0010-nfsd41-encode-replay-sequence-from-the-slot-values.patch
> 0011-nfsd41-fix-nfsd4_replay_cache_entry-comments.patch
> 0012-nfsd41-support-16-slots-per-session.patch
> 0013-nfsd41-add-test-for-failed-sequence-operation.patch
> 0014-nfsd41-remove-redundant-failed-sequence-check.patch
> 
> Comments welcome.
> 
> -->Andy
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
