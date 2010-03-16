From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] Should lockd get into grace_period when statd start but
	not stop?
Date: Tue, 16 Mar 2010 12:56:21 -0400
Message-ID: <20100316165621.GE4411@fieldses.org>
References: <4B9772EB.9010909@cn.fujitsu.com> <20100310182401.GA23340@fieldses.org> <4B98413F.1080609@cn.fujitsu.com> <20100311155857.GC22587@fieldses.org> <4B9A0C7A.1000001@cn.fujitsu.com> <20100312230804.GN13941@fieldses.org> <4B9F57ED.4090100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51179 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756656Ab0CPQyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 12:54:47 -0400
In-Reply-To: <4B9F57ED.4090100@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 16, 2010 at 06:05:33PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields :
> > On Fri, Mar 12, 2010 at 05:42:18PM +0800, Mi Jinlong wrote:
> >>
> >> J. Bruce Fields:
> >>> Our current NFS implementation just isn't designed to be able to shut
> >>> down some components while leaving others running.
> >>   Really? But the lockd started with nfs service start, but not nfslock service.
> >>   And, lockd can't stop with statd at the same time. 
> >>   Sometimes, the lockd will not synchronous with statd. Maybe this problem is a good example.
> > 
> > I'm sorry, I still don't understand.
> > 
> > Please take a look at section 3.1, 3.2, and 3.3 of the nfs-utils README
> > file.  That describes the order in which servers should be started and
> > stopped.
> 
>   Maybe that's my problem. 
>   The status of lockd and statd, when testing.
> 
>          lockd                statd
>            |                    |   <== service nfslock stop
>        get KILL signal        stopd   ^
>    and get into grace_period    |     |


I believe you also need to shut down nfsd here.

--b.

>            |                    |     | more than grace_period time
>            |                    |     v
>            |                    |   <== service nfslock start
>       normal state              |
>            |                  start   Client receive SM_NOTIFY and reclaime lock,
>            |                    |     but out of grace_period time.
>            v                    v
> 
>   As above, after nfslock service start, client cannot reclaime lock success.

