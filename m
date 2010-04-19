Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27930 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140Ab0DSX3k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 19:29:40 -0400
Subject: Re: [PATCH 00/24] Reduce the stack foot print of the NFS client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4BCCCE84.3050109@oracle.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
	 <4BCCCE84.3050109@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 19 Apr 2010 19:29:38 -0400
Message-ID: <1271719778.25129.73.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-04-19 at 17:43 -0400, Chuck Lever wrote: 
> On 04/16/2010 04:30 PM, Trond Myklebust wrote:
> > The following patch series aims to significantly reduce the stack foot
> > print of the NFS client by dynamically allocating the struct nfs_fattr
> > and struct nfs_fh.
> 
> Random comments:
> 
> 1.  There's an open-coded kzalloc of an nfs_fh in nfs_get_sb.  This can 
> be replaced with nfs_alloc_fh().

Added a clean up patch to do this.

> 2.  root_nfs_get_handle allocates an nfs_fh on the stack.  This can be 
> replaced with nfs_alloc_fh().

I suppose, although there will never be any danger of anyone calling
this function from any unexpected contexts. Anyhow, added a patch.

> 3.  There is an unneeded nfs_fattr_init() call in nfs_probe_fsinfo().  I 
> didn't look for others that are similarly made obsolete.

Fixed.

> 4.  Where ever you have "if (fattr == NULL) goto out;" (and similarly 
> for filehandles) you could add "unlikely()" to improve branch prediction 
> slightly.

No. While I agree that it is unlikely to fail, I prefer _not_ to have to
wade through all these likely()/unlikely() markups in order to read the
code. A quick perusal of other examples shows that I'm not alone in that
preference.

> 5.  The documenting comment before nfs_do_refmount() is out of date.

Fixed.

Cheers
  Trond
