From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 0/13] xdr macros cleanup
Date: Wed, 12 Aug 2009 18:15:07 +0300
Message-ID: <4A82DC7B.3090600@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:5951
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751724AbZHLPPL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:15:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I took a stab at eliminating the Xcoding macros in fs/nfs/nfs4xdr.c
by using generic xdr functions and local helpers that do not rely
on hidden side effects such as assigning to a pointer on the stack
or returning an error from the calling function.

The patches in this series are listed below.

Please let me know if this is the direction you were heading
and if ok with you I'd be happy to help with moving this
mini-project forward.

Benny

[PATCH RFC 01/13] sunrpc: hton -> cpu_to_be*
[PATCH RFC 02/13] sunrpc: ntoh -> be*_to_cpu
[PATCH RFC 03/13] sunrpc: introduce 32-bit Xcoding helpers
[PATCH RFC 04/13] nfs: nfs4xdr: get rid of WRITE32
[PATCH RFC 05/13] nfs: nfs4xdr: get rid of WRITE64
[PATCH RFC 06/13] nfs: nfs4xdr: get rid of WRITEMEM
[PATCH RFC 07/13] nfs: nfs4xdr: merge xdr_encode_int+xdr_encode_opaque_fixed into xdr_encode_opaque
[PATCH RFC 08/13] nfs: nfs4xdr: change RESERVE_SPACE macro into a static helper
[PATCH RFC 09/13] nfs: nfs4xdr: get rid of READ32
[PATCH RFC 10/13] nfs: nfs4xdr: get rid of READ64
[PATCH RFC 11/13] nfs: nfs4xdr: get rid of READTIME macro
[PATCH RFC 12/13] nfs: nfs4xdr: change COPYMEM macro into a static function
[PATCH RFC 13/13] nfs: nfs4xdr: get rid of READ_BUF
