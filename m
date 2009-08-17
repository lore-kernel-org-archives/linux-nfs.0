From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 17 Aug 2009 13:40:13 +0300
Message-ID: <4A89338D.1040207@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:1337
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757528AbZHQKkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2009 06:40:11 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/14/2009 05:17 PM, Benny Halevy wrote:
> Trond, thanks for your comments.
> I believe I've fixed them all.
> 
> Changes from v1:
> 
> - dropped xdr_{en,de}code_int, open code cpu_to_be32 and be32_to_cpup instead.
> - added helpers for decoding stateid, verifier, and sessionid
>   using a common helper for decoding fixed size opaque arrays.
> - COPYMEM calls all converted to memcpy (no need for returning ptr)
> - READ_BUF open coded, callers use print_overflow_msg as you suggested.
> 
> - minor cleanup in encode_compound_hdr
> - optimized nfs41 reserve_space usage
> - optimized low level encoding
> - simplified decode_exchange_id by reusing decode_opaque_inline
> - optimized low level decoding
> 
> In this patchset:
> 
> [PATCH RFC v2 01/21] sunrpc: hton -> cpu_to_be*
> [PATCH RFC v2 02/21] sunrpc: ntoh -> be*_to_cpu
> [PATCH RFC v2 03/21] nfs: nfs4xdr: get rid of WRITE32
> [PATCH RFC v2 04/21] nfs: nfs4xdr: get rid of WRITE64
> [PATCH RFC v2 05/21] nfs: nfs4xdr: get rid of WRITEMEM
> [PATCH RFC v2 06/21] nfs: nfs4xdr: optimize RESERVE_SPACE in encode_create_session and encode_sequence
> [PATCH RFC v2 07/21] nfs: nfs4xdr: encode_compound_hdr does not have to round up reserved bytes
> [PATCH RFC v2 08/21] nfs: nfs4xdr: change RESERVE_SPACE macro into a static helper
> [PATCH RFC v2 09/21] nfs: nfs4xdr: optimize low level encoding
> [PATCH RFC v2 10/21] nfs: nfs4xdr: merge xdr_encode_int+xdr_encode_opaque_fixed into xdr_encode_opaque
> [PATCH RFC v2 11/21] nfs: nfs4xdr: get rid of READ32
> [PATCH RFC v2 12/21] nfs: nfs4xdr: get rid of READ64
> [PATCH RFC v2 13/21] nfs: nfs4xdr: get rid of READTIME
> [PATCH RFC v2 14/21] nfs: nfs4xdr: introduce print_overflow_msg
> [PATCH RFC v2 15/21] nfs: nfs4xdr: introduce decode_opaque_fixed and decode_stateid helpers
> [PATCH RFC v2 16/21] nfs: nfs4xdr: introduce decode_verifier helper
> [PATCH RFC v2 17/21] nfs: nfs4xdr: introduce decode_sessionid helper
> [PATCH RFC v2 18/21] nfs: nfs4xdr: get rid of COPYMEM
> [PATCH RFC v2 19/21] nfs: nfs4xdr: simplify decode_exchange_id by reusing decode_opaque_inline
> [PATCH RFC v2 20/21] nfs: nfs4xdr: get rid of READ_BUF
> [PATCH RFC v2 21/21] nfs: nfs4xdr: optimize low level decoding
> 
> Benny

I'm very sorry that Benny has done all this work. I understand that it was a mess and
something should have been done. And I hope the final goal is to unify xdr stuff between
server and client, but ...

I hate what is done here!
As an imperfect human person, that coded these things and had bugs and was chasing them
for hours. These patches make my life much much harder. Not easier, sorry.

The READXX/WRITEXX macros was a romantic attempt at unification between server and client
and at "capitalizing" the actual encoding/decoding operations out of surrounding code, in
an attempt to hide a way all details. So a bug maker like me could attempt a visual side
by side comparison or counting of encode/decode operations, and fine the cure.

* So I hate it that the READ32/WRITE32 is open coded. Now it looks like nothing, it
  should have an xdr_encode/decode naming convention, all details hidden, consistent calling
  convention with the reset of the code.
* I hate it that I have to count (p)"++" now to look for actual code advancements.
* I hate that it is called encode_hyper that a dum like me needs to look it up in the dictionary
  "32" and "64" will do
* I hated it before, but I hate it even more now that the same operation is:
  reserved(4); p + 1
  I wish it could be all __be32 everywhere

Sometimes macros are good. When they try to make boring code pretty and cute.
These macros where evil but could be fixed. Also inline functions can be devised
for the same purpose. I do understand all these code theories, hell I wrote them,
but the practice of the matter is that these patches take me back not forward.
But perhaps it's just me?

Thanks
Boaz
