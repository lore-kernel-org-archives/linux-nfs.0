Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020Ab1K2V5o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 16:57:44 -0500
Message-ID: <1322603848.11286.7.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        bhalevy@tonian.com
Date: Tue, 29 Nov 2011 16:57:28 -0500
In-Reply-To: <4ED55399.4060707@panasas.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
	 <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 13:50 -0800, Boaz Harrosh wrote: 
> On 11/29/2011 01:34 PM, Boaz Harrosh wrote:
> > But just do the above and you'll see that it is perfect.
> > 
> > BTW don't limit the lo_segment size by the max_io_size. This is why you
> > have .bg_test to signal when IO is maxed out.
> > 
> > - The read segments should be as big as possible (i_size long)
> > - The Write segments should ideally be as big as the Application
> >   wants to write to. (Amount of dirty pages at time of nfs-write-out
> >   is a very good first approximation).
> > 
> > So I guess it is: I hate these patches, to much mess, too little goodness.
> > 
> > Thank
> > Boaz
> > 
> 
> Ho and one more thing.
> 
> Also Files when they will support segments and servers that request segments,
> like the CEPH server, will very much enjoy the above, .i.e: Tell me the amount
> you know you want to write.

Why would we want to add segment support to the pNFS files client???
Segments are a nuisance that multiply the amount of unnecessary chitchat
between the client and the MDS without providing any tangible
benefits...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

