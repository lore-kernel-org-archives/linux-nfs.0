From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/29] NFSv4.1 Server DRC rewrite
Date: Thu, 23 Apr 2009 19:41:15 -0400
Message-ID: <20090423234115.GO1906@fieldses.org>
References: <1240504988-9572-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51557 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbZDWXlP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:41:15 -0400
In-Reply-To: <1240504988-9572-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 12:42:39PM -0400, andros@netapp.com wrote:
> This is a rewrite of the NFSv4.1 DRC, switching from a page based cache to
> a buffer based cache. The logic for the single slot clientid cache has been
> separated from the session slot logic to handle the CREATE_SESSION call
> preceeded by a SEQUENCE and all the replay combinations therein.
> 
> The session DRC now caches encoded operations with the exception of the
> SEQUENCE operation which for a replay is encoded with the current slot and
> session values.  A review of message sizes indicates that a 1024 byte buffer
> for the operations is more than adequate.

Thanks, a quick skim suggests the basic idea's right.... I may not get
around to looking at this closer soon; let me know if there's a new
version at some point.

--b.

> 
> Not addressed is the necessary pre-operation processing estimate of the encoded
> per operation result to check against the negotiated fore channel maximum
> response size cached.
> 
> I've tested NFSv4.1 mounts using Connectathon and the new pynfs 4.1 tests,
> where I added two new Clientid cache replay tests [to be submitted]to
> st_create_session.py.
> 
> I've tested NFSv4.0 mounts using Connectathon and the pynfs v4.0 tests.
> 
> As always, comments and suggestions welcome.
> 
> -->Andy
> 
> Clientid single slot cache
> 0001-nfsd41-add-create-session-slot-buffer-to-struc-nfs4.patch
> 0002-nfsd41-encode-create_session-result-into-cache.patch
> 0003-nfsd41-create_session-check-replay-first.patch
> 0004-nfsd41-replay-solo-and-embedded-create-session.patch
> 0005-nfsd41-create_session-cache-hold-client-reference.patch
> 0006-nfsd41-no-nfsd4_release_respages-for-the-clientid-c.patch
> 0007-nfsd41-slots-are-freed-with-session.patch
> 
> Session slot cache
> 0008-nfsd41-protect-sv_drc_pages_used-with-spinlock.patch
> 0009-nfsd41-sanity-check-client-drc-maxreqs.patch
> 0010-nfsd41-change-from-page-to-memory-based-drc-limits.patch
> 0011-nfsd41-set-the-session-maximum-response-size-cached.patch
> 0012-nfsd41-allocate-and-use-drc-cache-buffers.patch
> 0013-nfsd41-free-drc-cache-buffers.patch
> 0014-nfsd41-obliterate-nfsd4_copy_pages.patch
> 0015-nfsd41-obliterate-nfsd41_copy_replay_data.patch
> 0016-nfsd41-obliterate-nfsd4_release_respages.patch
> 0017-nfsd41-remove-unused-nfsd4_cache_entry-fields.patch
> 0018-nfsd41-obliterate-nfsd4_set_statp.patch
> 0019-nfsd41-rename-nfsd4_enc_uncached_replay.patch
> 0020-nfsd41-encode-replay-sequence-from-the-slot-values.patch
> 0021-nfsd41-remove-iovlen-field-from-nfsd4_compound_stat.patch
> 0022-nfsd41-obliterate-nfsd41_copy_replay_data.patch
> 0023-nfsd41-fix-nfsd4_store_cache_entry-comments.patch
> 0024-nfsd41-support-16-slots-per-session.patch
> 0025-nfsd41-use-the-maximum-operations-per-compound-in-n.patch
> 0026-nfsd41-fix-nfsd4_store_cache_entry-dprintk.patch
> 0027-nfsd41-add-test-for-failed-sequence-operation.patch
> 0028-nfsd41-remove-redundant-failed-sequence-check.patch
> 0029-nfsd41-remove-check-for-session.patch
> 
> 
