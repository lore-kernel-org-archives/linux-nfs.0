From: Ian Kent <raven@themaw.net>
Subject: RE: ~800 mountpoint limitation
Date: Mon, 15 Dec 2003 21:33:35 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0312152113060.13254-100000@raven.themaw.net>
References: <16268.10212.717980.343124@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Ogden, Aaron A." <aogden@unocal.com>,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVsro-00011L-Qz
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 05:34:32 -0800
Received: from mail-09.iinet.net.au ([203.59.3.41] helo=mail.iinet.net.au)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AVsro-0001GK-4B
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 05:34:32 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <16268.10212.717980.343124@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 14 Oct 2003, Trond Myklebust wrote:

> >>>>> " " == Aaron A Ogden <Ogden> writes:
> 
>      > Excellent!  I was hoping that you were following the
>      > discussion.  It is something you can fix though?  It seems that
>      > RPC may be involved as well...
> 
>      > Is there any hope of a patch for 2.4.20+ or is this strictly
>      > 2.6 code?
> 
> I'm really too busy right now to do a backport for 2.4.x (hell, I'm
> even too busy to forward-port to 2.6.0-test7 8-().
> 
> That said, it shouldn't be hard to do. I've made sure that the 2.4.x
> and 2.6.x RPC code have been tracking one another, so there should be
> few real differences to worry about. For all I know, the patch may
> even apply without any changes...
> 

Hi Trond,

Well, I had a go at updating the patch to apply against 2.6.0-test11 
tonight. Hope this is something you wanted done.

There are a couple of things that I'm unsure about. Particularly a line in 
call_connect_status that is assigned a different state than what the 
original source in the patch had.

So, if you have a little time, could you check my work.

I have included a bunch of info in case you need it.

The patch lives at /pub/linux/kernel/people/raven/nfs. Included there are 
two files with names ending in 'questionable'. They where the only changes 
that I thought might need your attention. Additionally, I made a tar of 
the 'orig' and 'rej' files produced from applying the original patch in 
case you want to check them. I haven't tested this at all yet. I think it 
best to wait wait for your feedback as to the accuracy of the work.

If the patch is OK with you then I will have a go at back porting it to 
2.4. If Aaron is able to, we can have him hammer it to death and perhaps 
collect some performance data.

Comments please?

Ian




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
