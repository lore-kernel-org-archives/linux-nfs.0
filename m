Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9887 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754412Ab1K2WrY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 17:47:24 -0500
Message-ID: <1322606842.11286.33.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        bhalevy@tonian.com, Garth Gibson <garth@panasas.com>,
        Matt Benjamin <matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>
Date: Tue, 29 Nov 2011 17:47:22 -0500
In-Reply-To: <4ED55F78.205@panasas.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
	  <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>
	 <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 14:40 -0800, Boaz Harrosh wrote: 
> On 11/29/2011 01:57 PM, Trond Myklebust wrote:
> >> Also Files when they will support segments and servers that request segments,
> >> like the CEPH server, will very much enjoy the above, .i.e: Tell me the amount
> >> you know you want to write.
> > 
> > Why would we want to add segment support to the pNFS files client???
> > Segments are a nuisance that multiply the amount of unnecessary chitchat
> > between the client and the MDS without providing any tangible
> > benefits...
> > 
> 
> Your kidding right?
> 
> One: it is mandated by the Standard, This is not an option. So a perfectly
>      Standard complaint server is not Supported by Linux because we don't see
>      the point.

Bollocks.. Nothing is "mandated by the Standard". If the server doesn't
give us a full layout, then we fall back to write through MDS. Why dick
around with crap that SLOWS YOU DOWN.

> Two: There are already file-layout servers out there (multiple) which are
>      waiting for the Linux files-layout segment support, because the underline
>      FS requires Segments and now they do not work with the Linux client. These
>      are CEPH and GPFS and more.

Then they will have a _long_ wait....

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

