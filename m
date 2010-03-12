From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] Should lockd get into grace_period when statd start but
	not stop?
Date: Fri, 12 Mar 2010 18:08:04 -0500
Message-ID: <20100312230804.GN13941@fieldses.org>
References: <4B9772EB.9010909@cn.fujitsu.com> <20100310182401.GA23340@fieldses.org> <4B98413F.1080609@cn.fujitsu.com> <20100311155857.GC22587@fieldses.org> <4B9A0C7A.1000001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33775 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933368Ab0CLXGj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 18:06:39 -0500
In-Reply-To: <4B9A0C7A.1000001@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 12, 2010 at 05:42:18PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > Our current NFS implementation just isn't designed to be able to shut
> > down some components while leaving others running.
> 
>   Really? But the lockd started with nfs service start, but not nfslock service.
>   And, lockd can't stop with statd at the same time. 
>   Sometimes, the lockd will not synchronous with statd. Maybe this problem is a good example.

I'm sorry, I still don't understand.

Please take a look at section 3.1, 3.2, and 3.3 of the nfs-utils README
file.  That describes the order in which servers should be started and
stopped.

--b.
