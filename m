Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-annu.mail.uoguelph.ca ([131.104.91.36]:4087 "EHLO
	esa-annu.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab1LNDUd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Dec 2011 22:20:33 -0500
Date: Tue, 13 Dec 2011 22:20:31 -0500 (EST)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, honey@citi.umich.edu,
        Brent Welch <welch@panasas.com>, nfsv4@ietf.org,
        Steve Dickson <steved@redhat.com>
Message-ID: <1132749605.180867.1323832831990.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <4EE1EC49.6010000@panasas.com>
Subject: Re: [nfsv4] Slides from the pNFS BoF we delivered at LISA 11 - with
 attachment this time
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:
[good stuff snipped for brevity]
> 
> I have on my todo list a full osd (pnfs-objects) stack port to FreeBSD
> But that's in the far future.
> Meanwhile I'd suggest the pnfs-client-core to layout-driver API be
> closely
> crafted to match that of the Linux LD API so it could be kept the same
> code base.

Am I correct to assume that fs/nfs/nfsfilelayout* implements this API
for the file layout case? If so, I'll try and build glue that can use
that code unchanged (or at least minimally changed).

And Peter (I see you're on the cc list), is it possible to get a copy
of these files without any GPL? It looks like they have the U of Michigan
copyright, which I think should be fine for the FreeBSD folks, but then
there is

   MODULE_LICENSE("GPL");

in it, which I assume means it's GPL'd. (Basically, exactly the same file,
but released without this line, would make the FreeBSD folks happy, I think.)
(No rush on this, I can use GPL'd code, I just can't put it in the FreeBSD
source tree easily.) The same would apply to any other layout driver that
others, like Panasas or EMC might be willing to open source for FreeBSD.

And Boaz, thanks for the useful information. I'll probably start with
Fedora plus a patched kernel for a server to test against. (It sounds
like Steve is willing to help me out, since I haven't used "rpm" in
years and have never typed "git" in my life.:-)

Thanks everyone for your help with this, rick


> For example the pnfs-objects LD is mostly pure C code
> relying
> on the ORE (Objects Raid Engine). The ORE is multy licensed library
> that
> has ports to Many platforms including Linux-Kernel
> Linux/FreeBSD/windows User-Mode and more of which only the Linux
> variants
> actually run because of the need of the iscsi stack to support BiDi
> and
> large CDB commands, Only supported by Linux.
> 
> Cheers
> Boaz
> 
> > rick
> >
> > ----- Original Message -----
> >> On Thu, 08 Dec 2011 19:40:19 -0500, Sorin Faibish
> >> <sfaibish@emc.com>
> >> wrote:
> >>
> >>> Attached please find the slides that we presented yesterday at
> >>> USENIX
> >>> LISA 11
> >>> conference in Boston. We would like to get more detailed input on
> >>> other
> >>> OS
> >>> that will support pNFS server/client (this is for Rick as well)
> >>> that
> >>> were
> >>> not mentioned in this slide set.
> >>>
> >>> /Sorin
> >>>
> >>
> >>
> >>
> >> --
> >> Best Regards
> >> Sorin Faibish
> >> Corporate Distinguished Engineer
> >> Unified Storage Division
> >>
> >> EMC²
> >> where information lives
> >>
> >> Phone: 508-435-1000 x 48545
> >> Cellphone: 617-510-0422
> >> Email : sfaibish@emc.com
> > _______________________________________________
> > nfsv4 mailing list
> > nfsv4@ietf.org
> > https://www.ietf.org/mailman/listinfo/nfsv4
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
