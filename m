From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 02/47] sunrpc: add cl_private field to struct rpc_clnt
Date: Sat, 28 Mar 2009 13:23:55 -0400
Message-ID: <1238261035.6679.4.camel@heimdal.trondhjem.org>
References: <49CC40E5.2080506@panasas.com>
	 <1238122908-6967-1-git-send-email-bhalevy@panasas.com>
	 <20090328000552.GJ18222@fieldses.org>
	 <E166DD1F-96CC-4F61-B215-7CE5FCEF20C4@netapp.com>
	 <49CDDDBB.9060706@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54052 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbZC1RY3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Mar 2009 13:24:29 -0400
In-Reply-To: <49CDDDBB.9060706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-03-28 at 11:20 +0300, Benny Halevy wrote:
> On Mar. 28, 2009, 3:39 +0300, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > On Mar 27, 2009, at 8:06 PM, "J. Bruce Fields" <bfields@fieldses.org>  
> > wrote:
> > 
> >> On Fri, Mar 27, 2009 at 06:01:48AM +0300, Benny Halevy wrote:
> >>> From: Andy Adamson <andros@netapp.com>
> >>>
> >>> Note: the NFSv4.1 client also uses (and declares) this pointer.
> >> OK.  Ack from trond?
> > 
> > 
> > First, someone would need to remind me why it is necessary, and add  
> > that justification to the changelog.
> 
> First time this is used in this patchset is here:
> [PATCH 35/47] nfsd: minorversion support for the back channel
> 
> The client uses cl_private to determine the minorversion
> (via a struct nfs_client *) to be set in the compound header,
> and to know when to generate a SEQUENCE op.
> Similarly, the server puts a struct nfs4_callback * in
> there for callback compounds' CB_COMPOUND and CB_SEQUENCE.

Why would the rpc_client need to know and track minor versions? That is
an NFS protocol specific thing.

Besides, the caller should always know what minor version it is using.
It shouldn't need a back-pointer in the rpc_client...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
