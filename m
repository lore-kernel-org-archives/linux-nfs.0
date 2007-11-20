From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] rpc.statd
Date: Mon, 19 Nov 2007 20:23:08 -0500
Message-ID: <20071119202308.3f2430ec@tleilax.poochiereds.net>
References: <1b378070711191506o14ce99feo37c2a75bfdc4e47e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Shiney James" <shineyjames@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuHpZ-0007c0-Kh
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 17:23:13 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuHpe-00019B-Cq
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 17:23:19 -0800
In-Reply-To: <1b378070711191506o14ce99feo37c2a75bfdc4e47e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 19 Nov 2007 15:06:44 -0800
"Shiney James" <shineyjames@gmail.com> wrote:

> Hi,
> 
> I would greatly appreciate if someone could help me regarding the
> following..
> 
> >From the manuals it is understood that rpc.statd can configured to
> listen on a particular port for  incoming request and a port for
> outgoing request. This can be done by setting STATD_PORT and
> STATD_OUTGOING_PORT. But even after setting these I find that there is
> a port opened other than the above.
> 
> netstat -anop | grep rpc.statd output is pasted below.
> 
> [root@fs01 root]# netstat -anop | grep rpc.statd
> tcp        0      0 0.0.0.0:48000         0.0.0.0:*
> LISTEN      4334/rpc.statd      off (0.00/0/0)
> udp        0      0 0.0.0.0:48000           0.0.0.0:*
>          4334/rpc.statd      off (0.00/0/0)
> udp        0      0 0.0.0.0:694             0.0.0.0:*
>          4334/rpc.statd      off (0.00/0/0)
> unix  2      [ ]         DGRAM                    5378
> 4334/rpc.statd
> 
> I have set STATD_PORT as 48000 as is seen. But I am not sure why port
> 694 is also being used?
> Any idea?
> 
> Thanks
> Shiney
> 

It's for statd to make downcalls to the local lockd. The kernel
requires a privileged port for that...

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

