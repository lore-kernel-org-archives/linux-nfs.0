From: andros@netapp.com
Subject: [PATCH 0/29] NFSv4.1 Server DRC rewrite Version 2
Date: Tue, 28 Apr 2009 12:56:14 -0400
Message-ID: <1240937775-23746-1-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4995 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbZD1Q4R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 12:56:17 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Version 2 of the NFSv4.1 DRC rewrite.

V1 -> V2 Differences:

1) Separate structure for the single slot clientid cache because it does not
need several of the fields that the sessions multiple slot cache needs, and
has a different static cache buffer size.

2) Move from a dynamic to a static buffer allocation for the sessions DRC
because we can't promise the client to be able to cache a response and then
run out of memory and not be able to cache a response.
Switch from a 1024 byte to a 512 byte buffer.

3) Removed struct nfsd4_cache_entry, replaced by new nfsd4_slot fields.

4) Global DRC memory limit tracking.


This is a rewrite of the NFSv4.1 DRC, switching from a page based cache to
a buffer based cache. The logic for the single slot clientid cache has been
separated from the session slot logic to handle the CREATE_SESSION call
preceeded by a SEQUENCE and all the replay combinations therein.

The session DRC now caches encoded operations with the exception of the
SEQUENCE operation which for a replay is encoded with the current slot and
session values.  A review of message sizes indicates that a 512 byte buffer
for the operations is adequate.

Not addressed is the necessary pre-operation processing estimate of the encoded
per operation result to check against the negotiated fore channel maximum
response size cached.

I've tested NFSv4.1 mounts using Connectathon and the new pynfs 4.1 tests,
where I added two new Clientid cache replay tests [to be submitted]to
st_create_session.py.

I've tested NFSv4.0 mounts using Connectathon and the pynfs v4.0 tests.

As always, comments and suggestions welcome.

-->Andy

Bug fix
0001-nfsd41-slots-are-freed-with-session.patch

Clientid single slot cache
0002-nfsd41-change-check_slot_seqid-parameters.patch
0003-nfsd41-turn-off-create-session-caching.patch
0004-nfsd41-separate-clientid-slot-from-session-slot.patch
0005-nfsd41-encode-create_session-result-into-cache.patch
0006-nfsd41-create_session-check-replay-first.patch
0007-nfsd41-replay-solo-and-embedded-create-session.patch

Session slot cache
0008-nfsd41-sanity-check-client-drc-maxreqs.patch
0009-nfsd41-change-from-page-to-memory-based-drc-limits.patch
0010-nfsd41-use-globals-for-DRC-memory-use-management.patch
0011-nfsd41-set-the-session-maximum-response-size-cached.patch
0012-nfsd41-use-static-buffers-for-sessions-DRC.patch
0013-nfsd41-replace-ce_cachethis-with-nfsd4_slot-field.patch
0014-nfsd41-replace-ce_opcnt-with-nfsd4_slot-field.patch
0015-nfsd41-nfsd41-replace-ce_status-with-nfsd4_slot-fi.patch
0016-nfsd41-obliterate-nfsd4_copy_pages.patch
0017-nfsd41-obliterate-nfsd41_copy_replay_data.patch
0018-nfsd41-obliterate-nfsd4_release_respages.patch
0019-nfsd41-remove-iovlen-field-from-nfsd4_compound_stat.patch
0020-nfsd41-remove-struct-nfsd4_cache_entry.patch
0021-nfsd41-obliterate-nfsd4_set_statp.patch
0022-nfsd41-rename-nfsd4_enc_uncached_replay.patch
0023-nfsd41-encode-replay-sequence-from-the-slot-values.patch
0024-nfsd41-fix-nfsd4_replay_cache_entry-comments.patch
0025-nfsd41-fix-nfsd4_store_cache_entry-comments.patch
0026-nfsd41-support-16-slots-per-session.patch
0027-nfsd41-use-the-maximum-operations-per-compound-in-n.patch
0028-nfsd41-fix-nfsd4_store_cache_entry-dprintk.patch
0029-nfsd41-add-test-for-failed-sequence-operation.patch
0030-nfsd41-remove-redundant-failed-sequence-check.patch
0031-nfsd41-only-reference-the-session-on-non-replay-seq.patch

