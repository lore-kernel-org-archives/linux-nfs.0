Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51714 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab1GZQOP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 12:14:15 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
Date: Tue, 26 Jul 2011 09:14:13 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A5182A2@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110726160805.GA1922@merit.edu>
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com> <4E18614C.4010002@tonian.com> <F19688880B763E40B28B2B462677FBF805BF0610CE@MX09A.corp.emc.com> <1311621204.28209.14.camel@lade.trondhjem.org> <CA+a=Yy59HXXjd4HgrqeANaQZKO9rRPKzM+r3NNq2KSMV_L4S_w@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A51825D@SACMVEXC2-PRD.hq.netapp.com> <20110726160805.GA1922@merit.edu>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jim Rees" <rees@umich.edu>
Cc: "Peng Tao" <bergwolf@gmail.com>, <tao.peng@emc.com>,
        <linux-nfs@vger.kernel.org>, <bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Jim Rees [mailto:rees@umich.edu]
> Sent: Tuesday, July 26, 2011 12:08 PM
> To: Myklebust, Trond
> Cc: Peng Tao; tao.peng@emc.com; linux-nfs@vger.kernel.org;
> bhalevy@tonian.com
> Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
> 
> Myklebust, Trond wrote:
> 
>   > Thanks for your explanation. Is there any plan on how to fix
>   > pnfs_ld_read/write_done? Basically, we would need an interface
that
>   > can redirect the IO to MDS if pnfs_error is set or do all
necessary
>   > cleanup work to end read/write if pnfs_error is 0. IMHO, the
>   > recoalesce logic need to access nfs_pageio_descriptor but we do
not
>   > have that information at pnfs_ld_read/write_done.
> 
>   As far as I can see, the right thing to do is to mark the layout as
>   invalid and then redirty the page. It should be easy to have fsync()
>   re-send the pages in this case. These should be extremely rare
> events,
>   since we expect to catch most of the pNFS failures when we do the
> actual
>   LAYOUTGET in the ->pg_init().
> 
>   My main worry is for aio/dio where there is no good mechanism for
>   retrying. I'm still working on that...
> 
> What do you suggest we do for the current set of patches that add
block
> layout to pnfs?

If you are calling pnfs_ld_read/write_done, then don't change anything:
it is easier to fix this in one spot rather than several.
However someone needs to start working on fixing the code in
pnfs_ld_read/write_done to do the right thing. If nobody else has the
cycles, then I can do that but I'd prefer to have someone who can easily
test the resulting code do it.

Cheers
  Trond
