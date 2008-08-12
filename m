From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 0/2] fix nfsd stateid encoding
Date: Tue, 12 Aug 2008 15:14:39 -0400
Message-ID: <20080812191439.GD30729@fieldses.org>
References: <48A04820.5000409@panasas.com> <20080811155842.GC32193@fieldses.org> <48A064BC.1050302@panasas.com> <76bd70e30808110917y5a9a1950l1d905f081bd7a819@mail.gmail.com> <20080811162830.GB772@fieldses.org> <48A0796F.20402@panasas.com> <20080811175026.GA1781@fieldses.org> <48A1CB0C.4090906@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chucklever@gmail.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60262 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbYHLTOo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2008 15:14:44 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2008 at 08:40:28PM +0300, Benny Halevy wrote:
> OK.  It's better to separate the fixes from the refactoring of code.
> The 7-patch patchset in reply to this message does the following:
> 
> [PATCH 1/7] nfsd: properly xdr-encode stateid4.seqid as uint32_t for cb_recall
> 
> encoding fix for cb_recall.
> 
> There's no helper defined since there's only one use.
> I've defined a helper and used in the nfs41 series since
> there, there are 2 (cb_recall and cb_layoutrecall).
> 
> [PATCH 2/7] nfsd: properly xdr-encode deleg stateid returned from open
> [PATCH 3/7] nfsd: fix nfsd4_encode_open buffer space reservation
> 
> xdr encoding fixes
> 
> [PATCH 4/7] nfsd: nfs4xdr encode_stateid helper function
> [PATCH 5/7] nfsd: don't declare p in ENCODE_SEQID_OP_HEAD
> 
> 
> xdr encode_stateid refactoring
> 
> [PATCH 6/7] nfsd: properly xdr-decode NFS4_OPEN_CLAIM_DELEGATE_CUR stateid
> 
> xdr decoding fix
> 
> [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
> 
> xdr decode_stateid refactoring

Thanks, all applied to

	git://linux-nfs.org/~bfields/linux.git for-2.6.28

--b.
