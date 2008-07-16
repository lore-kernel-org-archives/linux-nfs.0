From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/2 v4] nfs: return nfs4 compound header status on op
 header decoding error
Date: Wed, 16 Jul 2008 11:21:03 +0300
Message-ID: <487DAF6F.10404@panasas.com>
References: <47F0F6AB.3030302@panasas.com>	 <1206974900-368-1-git-send-email-bhalevy@panasas.com>	 <1207002349.15341.15.camel@heimdal.trondhjem.org>	 <47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>	 <4824E08E.6070401@panasas.com> <1210440276.12927.0.camel@localhost>	 <48277F7B.2060307@panasas.com>  <486D110F.1010608@panasas.com> <1216159035.7981.70.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:8331 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751628AbYGPIVZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2008 04:21:25 -0400
In-Reply-To: <1216159035.7981.70.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 16, 2008, 0:57 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2008-07-03 at 20:49 +0300, Benny Halevy wrote:
>> Trond,  following our conversation during the Connectathon
>> I reduced this patch as much as possible and restricted the
>> use of the compound header status to cases where op_hdr
>> decoding hit an error.
>>
>> This is needed for nfs41 for graceful fallback when trying
>> to mount a 4.0 server with 4.1.  In this case the server
>> returns no ops and the hdr status is set to
>> NFS4ERR_MINOR_VERS_MISMATCH.
>>
>> Please consider these patches:
>>
>> [PATCH 1/2] nfs: return nfs4 compound header status on op header decoding error
> 
> No, this patch doesn't look right either. If we overrun the end of the
> reply buffer, then xdr_inline_decode() will return a NULL pointer, so
> you should never hit the your (opnum != expected) case.

In patch 1, this is supposed to be handled like this:

decode_compound_hdr:
+	xdr->status = hdr->status;

decode_op_hdr:
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p)) {
...
+		goto err;
+	}

+err:
+	if (xdr->status != NFS_OK)
+		return nfs4_stat_to_errno(xdr->status);

> 
> So given that your concern is primarily the case where nops==0, why
> don't you just add that particular case to decode_compound_hdr?
> 
> IOW: something like
> 
> 
> @@static int decode_compound_hdr(
> 	p += XDR_QUADLEN(hdr->taglen);
> 	READ32(hdr->nops);
> +	if (hdr->nops < 1)
> +		return nfs4_stat_to_errno(hdr->status);
> 	return 0;
> }
> 

This certainly provides a shortcut for the nops==0 case.
However, it doesn't solve the OP_ILLEGAL case all other
cases where xdr_inline_decode failed or opnum != expected,
we can easily handle the OP_ILLEGAL case explicitly in
decode_op_hdr.  Are you ok with the approach of
carrying the hdr.status in xdr->status for decode_op_hdr
use, or do you rather prefer to leave things as they are
for the invalid cases and explicitly handle only the
nops==0 and OP_ILLEGAL cases?

Benny
