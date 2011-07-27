Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54027 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753454Ab1G0UZX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:25:23 -0400
Subject: Re: [PATCH v3 06/25] pnfs: cleanup_layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 16:25:22 -0400
In-Reply-To: <4E3072F3.7090802@panasas.com>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
		 <1311792048-12551-7-git-send-email-rees@umich.edu>
	 <1311796389.25645.20.camel@lade.trondhjem.org>
	 <4E3072F3.7090802@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311798322.25645.35.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 13:20 -0700, Boaz Harrosh wrote: 
> On 07/27/2011 12:53 PM, Trond Myklebust wrote:
> >> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> >> index bddd8b9..f271425 100644
> >> --- a/fs/nfs/pnfs.h
> >> +++ b/fs/nfs/pnfs.h
> >> @@ -113,6 +113,9 @@ struct pnfs_layoutdriver_type {
> >>  				     struct xdr_stream *xdr,
> >>  				     const struct nfs4_layoutreturn_args *args);
> >>  
> >> +	void (*cleanup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> >> +				      struct nfs4_layoutcommit_data *data);
> >> +
> >>  	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> >>  				     struct xdr_stream *xdr,
> >>  				     const struct nfs4_layoutcommit_args *args);
> > 
> > This really needs to go. We should have
> > 
> >       int (*layoutcommit)()...
> > 
> > instead of 'encode' and 'cleanup' methods...
> > 
> 
> Theoretically it is not possible because the blocks-layout protocol mandates
> different handling depending on the "error" response from the Server which
> will be received on RPC done.

???? If the blocks code is in charge of actually doing the RPC call, why
would it not be able to perform its own error handling?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

