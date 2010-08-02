Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48871 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753511Ab0HBNvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Aug 2010 09:51:55 -0400
Date: Mon, 2 Aug 2010 09:50:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "nfsd4: distinguish expired from stale stateids"
Message-ID: <20100802135036.GA12637@fieldses.org>
References: <20100518233746.GC26911@fieldses.org>
 <4C563CE5.1010101@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C563CE5.1010101@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 02, 2010 at 11:35:01AM +0800, Bian Naimeng wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > This reverts commit 78155ed75f470710f2aecb3e75e3d97107ba8374.
> > 
> > We're depending here on the boot time that we use to generate the
> > stateid being monotonic, but get_seconds() is not necessarily.
> > 
> > We still depend at least on boot_time being different every time, but
> > that is a safer bet.
> > 
> > We have a few reports of errors that might be explained by this problem,
> > though we haven't been able to confirm any of them.
> > 
> > But the minor gain of distinguishing expired from stale errors seems not
> > worth the risk.
> > 
> 
>   Hi bruce, if remove this patch, some my test will fail. So what's your opinion
>   for those test case.
> 
>     STEP1: open the file, and get a open stateid (STATEID).
>     STEP2: shutdown the network between client and server
>     STEP3: keep the network partition lease_time(90s by default) seconds
>     STEP4: recovery network
>     STEP5: do some IO operation, such as LOCK.
> 
>   If i use the patch 78155ed75f470710f2aecb3e75e3d97107ba8374, this case will OK
>   at STEP5,  however, it's will fail when remove this patch.

How does it fail, exactly?

> 
>   So i think it's no good for the network recovery, what do you think about it, 
>   or give me some suggestions, thanks very much.

The theoretical problem with the patch is that time changes could cause
the server to return spurious errors when the client hands it state that
should still be good.

We might be able to solve that by using a different time source?

--b.
