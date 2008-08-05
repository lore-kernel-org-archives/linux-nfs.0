From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: nfs-utils and unfsd
Date: Tue, 5 Aug 2008 21:24:45 +0200
Message-ID: <200808052124.45907.bernd-schubert@gmx.de>
References: <959E2970-49E6-425C-A10D-2D486913CD3F@oracle.com> <48989831.2030808@RedHat.com> <BFA7510D-B3C2-48FB-8C17-80008A362B6D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:60099 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1761681AbYHETZB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2008 15:25:01 -0400
In-Reply-To: <BFA7510D-B3C2-48FB-8C17-80008A362B6D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 05 August 2008, Chuck Lever wrote:
> On Aug 5, 2008, at 2:13 PM, Steve Dickson wrote:
> > Chuck Lever wrote:
> >> There is a generic RPC server helper in nfs-utils called rpc_init().
> >> This API will need to be modified to support IPv6 in statd and
> >> mountd,
> >> at least.
> >>
> >> However, there is a comment inside support/nfs/rpcmisc.c, where
> >> rpc_init() resides, that suggests that this interface is also used by
> >> unfsd.
> >>
> >> Is it OK for me to modify nfs-utils' copy of this function, or is
> >> there
> >> any kind of ABI restriction between unfsd and nfs-utils?
> >
> > I don't see any problem... Is there even a supported/maintained
> > version
> > of unfsd out there today? I did a quick google search and didn't find
> > anything but man pages...
>
> I found this ancient web page:
>
> http://rpm.pbone.net/index.php3/stat/4/idpl/6572509/com/unfs3-0.9.20-1.el3.
>pp.i386.rpm.html
>
> which suggests there is no binary dependency between unfsd and nfs-
> utils.

This is unfs3, which is a rewritten from scratch by Pascal Schmidt and so 
unrelated to unfsd.
