From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: [PATCH 0/3] code review fixes
Date: Wed, 17 Jun 2009 13:20:30 -0400
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C568@daytona.int.panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <pnfs@linux-nfs.org>, <linux-nfs@vger.kernel.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:14401
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753697AbZFQRUq convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 13:20:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

The following patches fix the remaining review comments for the
nfs41 for 2.6.31 series (non-callback code).

[PATCH 1/3] SQUASHME: nfs41: no need to break read_buf in decode_compound_hdr_arg
[PATCH 2/3] SQUASHME: nfs41: refactor op preprocessing out of process_op

Note that this patch changes the nfsv4.0 behavior also when
CONFIG_NFS_V4_1 is not defined where NFS4ERR_MINOR_VERS_MISMATCH
will be returned if the client received a CB_COMPOUND
with minorversion != 0.  Previously, it would have
returned NFS4ERR_OP_ILLEGAL for CB_SEQUENCE.
(or if the server is broken and sent OP_CB_GETATTR or OP_CB_RECALL
with minorversion!=0, they would have been processed normally.

[PATCH 3/3] SQUASHME: nfs41: get rid of READ64 in callback_xdr.c

Benny


