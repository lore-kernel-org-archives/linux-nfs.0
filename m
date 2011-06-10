Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756472Ab1FJRcI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 13:32:08 -0400
Subject: Re: [PATCH 4/5] NFSv4.1: Add an initialisation callback for pNFS
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Date: Fri, 10 Jun 2011 13:32:20 -0400
In-Reply-To: <4DF24CF0.3030507@panasas.com>
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com>
		 <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com>
		 <1307669462-15764-3-git-send-email-Trond.Myklebust@netapp.com>
		 <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com>
		 <4DF1871C.1070001@panasas.com> <4DF19841.5030904@panasas.com>
		 <4DF19D7B.2060308@panasas.com> <4DF1A106.3070205@panasas.com>
		 <4DF242D7.4030607@panasas.com>
	 <1307723298.19554.8.camel@lade.trondhjem.org>
	 <4DF24CF0.3030507@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1307727140.19554.19.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-06-10 at 09:57 -0700, Boaz Harrosh wrote: 
> On 06/10/2011 09:28 AM, Trond Myklebust wrote:
> >>
> >> That makes it even more complicated for a do nothing function. We dont do
> >> a different function for each different parameter. We can just do a 
> >> "bool write" and unify the dam thing
> > 
> > Right now, the nfs_pageio_descriptor doesn't know about reads vs writes.
> > It just knows about 'coalesce requests' and 'perform i/o'. I'd prefer to
> > keep that abstraction, as it makes things cleaner, particularly when you
> > get to patch 5 (NFSv4.1: Fall back to ordinary i/o through the mds if we
> > have no layout segment). Why add more 'if' statements when you don't
> > need to...
> > 
> 
> OK It's fine. I'm convinced. Do you have this on a git tree? I want to test
> it out. 

I've added it to the 'nfs-for-bakeathon' branch.

> What was the disposition of desc->pg_bsize do I need to adjust it for the
> pnfs_case in objlayout?

You might need to adjust it. Please check...

I'm still working on the 'fallback to write through mds' case to ensure
that we re-coalesce if the call to pnfs_try_to_read_data() and
pnfs_try_to_write_data(). Once that is done, I think that the objects
code will always do the right thing and I anticipate that the blocks
code can reuse the same code...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

