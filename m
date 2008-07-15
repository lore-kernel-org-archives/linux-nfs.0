From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/2 v4] nfs: return nfs4 compound header status on op
	header decoding error
Date: Tue, 15 Jul 2008 17:57:15 -0400
Message-ID: <1216159035.7981.70.camel@localhost>
References: <47F0F6AB.3030302@panasas.com>
	 <1206974900-368-1-git-send-email-bhalevy@panasas.com>
	 <1207002349.15341.15.camel@heimdal.trondhjem.org>
	 <47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>
	 <4824E08E.6070401@panasas.com> <1210440276.12927.0.camel@localhost>
	 <48277F7B.2060307@panasas.com>  <486D110F.1010608@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47277 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbYGOV5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 17:57:20 -0400
In-Reply-To: <486D110F.1010608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-07-03 at 20:49 +0300, Benny Halevy wrote:
> Trond,  following our conversation during the Connectathon
> I reduced this patch as much as possible and restricted the
> use of the compound header status to cases where op_hdr
> decoding hit an error.
> 
> This is needed for nfs41 for graceful fallback when trying
> to mount a 4.0 server with 4.1.  In this case the server
> returns no ops and the hdr status is set to
> NFS4ERR_MINOR_VERS_MISMATCH.
> 
> Please consider these patches:
> 
> [PATCH 1/2] nfs: return nfs4 compound header status on op header decoding error

No, this patch doesn't look right either. If we overrun the end of the
reply buffer, then xdr_inline_decode() will return a NULL pointer, so
you should never hit the your (opnum != expected) case.

So given that your concern is primarily the case where nops==0, why
don't you just add that particular case to decode_compound_hdr?

IOW: something like


@@static int decode_compound_hdr(
	p += XDR_QUADLEN(hdr->taglen);
	READ32(hdr->nops);
+	if (hdr->nops < 1)
+		return nfs4_stat_to_errno(hdr->status);
	return 0;
}

