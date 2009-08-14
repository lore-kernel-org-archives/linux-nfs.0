From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Fri, 14 Aug 2009 17:17:06 +0300
Message-ID: <4A8571E2.8020800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:28986
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755671AbZHNORS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:17:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, thanks for your comments.
I believe I've fixed them all.

Changes from v1:

- dropped xdr_{en,de}code_int, open code cpu_to_be32 and be32_to_cpup instead.
- added helpers for decoding stateid, verifier, and sessionid
  using a common helper for decoding fixed size opaque arrays.
- COPYMEM calls all converted to memcpy (no need for returning ptr)
- READ_BUF open coded, callers use print_overflow_msg as you suggested.

- minor cleanup in encode_compound_hdr
- optimized nfs41 reserve_space usage
- optimized low level encoding
- simplified decode_exchange_id by reusing decode_opaque_inline
- optimized low level decoding

In this patchset:

[PATCH RFC v2 01/21] sunrpc: hton -> cpu_to_be*
[PATCH RFC v2 02/21] sunrpc: ntoh -> be*_to_cpu
[PATCH RFC v2 03/21] nfs: nfs4xdr: get rid of WRITE32
[PATCH RFC v2 04/21] nfs: nfs4xdr: get rid of WRITE64
[PATCH RFC v2 05/21] nfs: nfs4xdr: get rid of WRITEMEM
[PATCH RFC v2 06/21] nfs: nfs4xdr: optimize RESERVE_SPACE in encode_create_session and encode_sequence
[PATCH RFC v2 07/21] nfs: nfs4xdr: encode_compound_hdr does not have to round up reserved bytes
[PATCH RFC v2 08/21] nfs: nfs4xdr: change RESERVE_SPACE macro into a static helper
[PATCH RFC v2 09/21] nfs: nfs4xdr: optimize low level encoding
[PATCH RFC v2 10/21] nfs: nfs4xdr: merge xdr_encode_int+xdr_encode_opaque_fixed into xdr_encode_opaque
[PATCH RFC v2 11/21] nfs: nfs4xdr: get rid of READ32
[PATCH RFC v2 12/21] nfs: nfs4xdr: get rid of READ64
[PATCH RFC v2 13/21] nfs: nfs4xdr: get rid of READTIME
[PATCH RFC v2 14/21] nfs: nfs4xdr: introduce print_overflow_msg
[PATCH RFC v2 15/21] nfs: nfs4xdr: introduce decode_opaque_fixed and decode_stateid helpers
[PATCH RFC v2 16/21] nfs: nfs4xdr: introduce decode_verifier helper
[PATCH RFC v2 17/21] nfs: nfs4xdr: introduce decode_sessionid helper
[PATCH RFC v2 18/21] nfs: nfs4xdr: get rid of COPYMEM
[PATCH RFC v2 19/21] nfs: nfs4xdr: simplify decode_exchange_id by reusing decode_opaque_inline
[PATCH RFC v2 20/21] nfs: nfs4xdr: get rid of READ_BUF
[PATCH RFC v2 21/21] nfs: nfs4xdr: optimize low level decoding

Benny
