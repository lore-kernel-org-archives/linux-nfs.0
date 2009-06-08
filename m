From: andros@netapp.com
Subject: [PATCH 0/30] NFSv4.1 Server DRC rewrite Version 3
Date: Mon,  8 Jun 2009 14:20:41 -0400
Message-ID: <1244485271-7461-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24915 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961AbZFHSVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:12 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.1 Server DRC rewrite Version 3

This patch set applies to 2.6.30-rc8 and is the third version of the NFSv4.1
server DRC rewrite. As per Bruce Field's suggestion, the clientid cache for
CREATE_SESSION operations has been changed from storing the encoded response
to storing struct nfsd4_create_session, the CREATE_SESSION xdr structure.

The NFSv4.1 DRC is changed from a page based cache to
a buffer based cache. The logic for the single slot clientid cache has been
separated from the session slot logic to handle the CREATE_SESSION call
preceeded by a SEQUENCE and all the replay combinations therein.

The session DRC now caches encoded operations with the exception of the
SEQUENCE operation which for a replay is encoded with the current slot and
session values.  A review of message sizes indicates that a 512 byte buffer
for the operations is adequate.

Not addressed is replacing the nfsd4_check_drc_limit() post-operation checking 
with a pre-operation processing estimate of the encoded per operation result.

Testing:
4.1 mount: Connectathon and 4.1pynfs including the new create session replay
tests.
4.0 mount; Connectathon.


Clientid (create session operation) single slot DRC patches

0001-nfsd41-create_session-check-replay-first.patch
0002-nfsd41-change-check_slot_seqid-parameters.patch
0003-nfsd41-declare-clientid-create-session-slot-structu.patch
0004-nfsd41-encode-create_session-result-into-clid-cache.patch
0005-nfsd41-replay-solo-and-embedded-create-session.patch
0006-nfsd41-remove-the-unused-nfsd4_slot-create-session-s.patch

Sessions (sequence operation) multiple slot DRC patches.

0007-nfsd41-sanity-check-client-drc-maxreqs.patch
0008-nfsd41-change-from-page-to-memory-based-drc-limits.patch
0009-nfsd41-use-globals-for-DRC-memory-use-management.patch
0010-nfsd41-set-the-session-maximum-response-size-cached.patch
0011-nfsd41-use-static-buffers-for-sessions-DRC.patch
0012-nfsd41-replace-ce_cachethis-with-nfsd4_slot-field.patch
0013-nfsd41-replace-ce_opcnt-with-nfsd4_slot-field.patch
0014-nfsd41-nfsd41-replace-ce_status-with-nfsd4_slot-fi.patch
0015-nfsd41-obliterate-nfsd4_copy_pages.patch
0016-nfsd41-obliterate-nfsd41_copy_replay_data.patch
0017-nfsd41-obliterate-nfsd4_release_respages.patch
0018-nfsd41-remove-iovlen-field-from-nfsd4_compound_stat.patch
0019-nfsd41-remove-struct-nfsd4_cache_entry.patch
0020-nfsd41-obliterate-nfsd4_set_statp.patch
0021-nfsd41-rename-nfsd4_enc_uncached_replay.patch
0022-nfsd41-encode-replay-sequence-from-the-slot-values.patch
0023-nfsd41-fix-nfsd4_replay_cache_entry-comments.patch
0024-nfsd41-fix-nfsd4_store_cache_entry-comments.patch
0025-nfsd41-support-16-slots-per-session.patch
0026-nfsd41-use-the-maximum-operations-per-compound-in-n.patch
0027-nfsd41-fix-nfsd4_store_cache_entry-dprintk.patch
0028-nfsd41-add-test-for-failed-sequence-operation.patch
0029-nfsd41-remove-redundant-failed-sequence-check.patch
0030-nfsd41-only-reference-the-session-on-non-replay-seq.patch
patch-message.txt

Comments welcome.

-->Andy


