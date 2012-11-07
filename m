Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8800 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab2KGUf5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Nov 2012 15:35:57 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andrey Borzenkov <arvidjaar@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Effective process GID is ignored when client creates file on NFS
Date: Wed, 7 Nov 2012 20:35:55 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092AE579@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAA91j0VBWhT58iyNDTMXVnMU8skJTEwHyezD_HyhmaqW5+pt3w@mail.gmail.com>
	<20121107191336.GE7421@fieldses.org> <20121107232801.27afef92@opensuse.site>
In-Reply-To: <20121107232801.27afef92@opensuse.site>
Content-Type: text/plain; charset="koi8-r"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Andrey Borzenkov
> Sent: Wednesday, November 07, 2012 2:28 PM
> To: J. Bruce Fields
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Effective process GID is ignored when client creates file on NFS
> 
> В Wed, 7 Nov 2012 14:13:36 -0500
> "J. Bruce Fields" <bfields@fieldses.org> пишет:
> 
> > On Mon, Oct 29, 2012 at 06:09:29PM +0400, Andrey Borzenkov wrote:
> > > I have met application that is badly broken when installed on NFS.
> > > The reason is - it expects files to belong to specific group. It
> > > switches to this group on startup (explicit setgid) and creates
> > > files. But files come out as belonging to GID 0.
> > >
> > > I finally reduced it to this trivial script:
> > >
> > > === cut here ===
> > > #include <sys/types.h>
> > > #include <sys/stat.h>
> > > #include <fcntl.h>
> > > #include <unistd.h>
> > >
> > > main()
> > > {
> > >         int fd;
> > >
> > >         setgid(107);
> > >         fd = open("bar", O_CREAT, 0666);
> > >         close(fd);
> > > }
> > > === cut here ===
> > >
> > > On local storage file comes with GID 107; on NFS file comes with GID
> > > 0.
> > >
> > > Linux is SLES10 SP3 with relatively old kernel:
> > > 2.6.16.60-0.89.1-smp, server(s) are NetApp with different Data ONTAP
> > > versions (7.x and 8.1.1 as the last).
> > >
> > > Client passes correct credentials (UID:0, GID:107), but does not
> >
> > Those are the credentials in the rpc header on the CREATE call?
> >
> 
> Yes.
> 
> > > explicitly request file ownership in CREATE call (uid set_it - 0,
> > > gid set_it - 0).
> >
> > The client shouldn't have to set the owner or group itself.
> >
> > So this is server behavior.
> >
> > Have you checked that the directory you're creating in doesn't have
> > the sgid bit?
> 
> Yes. It does not.
> 
> >              Or perhaps there's some other server configuration that
> > causes this.
> 
> It appears that server ignores passed group if UID == 0. It correctly creates
> files if UID != 0. I got bug number from support but it is non-public and no
> information is visible so far. I asked about possible workaround (or
> undocumented options) but have not got any reply as yet.

So is it possible that you forgot to turn off root squashing on the server before testing?

Cheers
  Trond
