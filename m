From: "Chris Fanning" <christopher.fanning@gmail.com>
Subject: Re: [NFS] fd cache inconsistency!
Date: Tue, 15 Jan 2008 18:15:26 +0100
Message-ID: <215ff4410801150915g6142b65ch2fc55f2cd332a333@mail.gmail.com>
References: <215ff4410801150718o28118bc8me7d344b303e00306@mail.gmail.com>
	<20080115164440.GC17937@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54171 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422AbYAORPn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 12:15:43 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JEpO1-0003Oi-Ab
	for linux-nfs@vger.kernel.org; Wed, 16 Jan 2008 04:15:41 +1100
In-Reply-To: <20080115164440.GC17937@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 15, 2008 5:44 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, Jan 15, 2008 at 04:18:10PM +0100, Chris Fanning wrote:
> > Hi all,
> >
> > In my syslog I'm getting lots of these.
> >
> > nfsd[1926]: fd cache inconsistency!
> > last message repeated 31 times
> >
> > Does anyone know what it means?
>
> No.  In fact, I can't find that message in the current kernel or
> nfs-utils.  What versions of those are you using?

/usr/sbin/rpc.nfsd -v
Universal NFS Server 2.2beta47

uname -r
2.6.16-xen

Is that what you're looking for?

I'm using this same xen image at four different sites and only get
this error (warning) at one of them.
The only difference (that I can think of) betwwen this site and the
other three, it that here I share the same export to two different ip
ranges. At the other sites the share is only exported to one range.

/opt/ltsp-4.2u4       192.168.178.0/255.255.255.0(ro,no_root_squash,sync)
/opt/ltsp-4.2u4       10.200.61.0/255.255.255.0(ro,no_root_squash,sync)

I thought the xen image may have become corrupted so I replaced it
today. It hasn't helped.

What else may I consider?

Thanks.
Chris.


>  You may want to
> report this to your distro.
>
> --b.
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

