From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] rpc.statd
Date: Tue, 20 Nov 2007 05:39:29 -0500
Message-ID: <20071120053929.6099a595@tleilax.poochiereds.net>
References: <1b378070711191506o14ce99feo37c2a75bfdc4e47e@mail.gmail.com>
	<20071119202308.3f2430ec@tleilax.poochiereds.net>
	<1b378070711191806v55fb915fnb2949a8aca03c52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Shiney James" <shineyjames@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuQVs-0003Qs-2w
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 02:39:28 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuQVx-0007aZ-TY
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 02:39:34 -0800
In-Reply-To: <1b378070711191806v55fb915fnb2949a8aca03c52-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 19 Nov 2007 18:06:53 -0800
"Shiney James" <shineyjames@gmail.com> wrote:

> Thanks a lot for the information. I would like to know if there is a
> way to configure this port?
> Can a port already specified in /etc/services be used for the purpose?
> 

I don't think so. I think it just uses bindresvport to find the first
available port that's not designated for a service.
-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

