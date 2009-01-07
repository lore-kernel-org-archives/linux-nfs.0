From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/6] NFSD: minor cleanups for 2.6.29
Date: Wed, 7 Jan 2009 17:38:49 -0500
Message-ID: <20090107223849.GL965@fieldses.org>
References: <49469601.7020101@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pnfs mailing list <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:56977 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932427AbZAGWiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2009 17:38:52 -0500
In-Reply-To: <49469601.7020101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 15, 2008 at 07:38:09PM +0200, Benny Halevy wrote:
> Bruce,  following are half a dozen patches
> from the nfs41/pnfs tree
> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd-for-2.6.29

Thanks, applied.--b.

> 
> [PATCH 1/6] nfsd: add etoosmall to nfserrno
> [PATCH 2/6] nfsd: dprint each op status in nfsd4_proc_compound
> [PATCH 3/6] nfsd: git rid of nfs4_cb_null_ops declaration
> [PATCH 4/6] nfsd: delete wrong file comment from nfsd/nfs4xdr.c
> [PATCH 5/6] nfsd: last_byte_offset
> [PATCH 6/6] nfsd: get rid of NFSD_VERSION
> 
> Benny
