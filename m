From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] NFSD: fix handling of unsupported nfsv4 ops
Date: Wed, 4 Mar 2009 16:02:00 -0500
Message-ID: <20090304210200.GG28951@fieldses.org>
References: <49A6FD82.6080808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs mailing list <pnfs@linux-nfs.org>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52062 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbZCDVCF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 16:02:05 -0500
In-Reply-To: <49A6FD82.6080808@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 26, 2009 at 12:37:22PM -0800, Benny Halevy wrote:
> Both patches fix issues I introduced in 2.6.27.
> The first one is more crucial to get to the 2.6.2{7,8} stable streams
> but while at it, I'd pull both.
> This was triggered in connectathon with the Sun OpenSolaris
> client trying to read extended attrs (when copying a file).
> This translates to a NFS4 OP_OPENATTR which caused our server to barf.

Thanks!  But, sorry, somehow I didn't get both of these (probably a
screwup on my end); would you mind resending?

Also, have you checked to make sure there aren't any other holes in our
list of operations?

--b.

> 
> [PATCH 1/2] NFSD: provide encode routine for OP_OPENATTR
> [PATCH 2/2] NFSD: return nfsv4 error code nfserr_notsupp rather than nfsv[23]'s nfserr_opnotsupp
> 
> Benny
