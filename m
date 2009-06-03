From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: libtirpc and nis
Date: Wed, 3 Jun 2009 18:44:32 -0400
Message-ID: <200906031844.34398.vapier@gentoo.org>
References: <200906031002.38551.vapier@gentoo.org> <4A269364.2080304@RedHat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:45156 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753965AbZFCWoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 18:44:32 -0400
In-Reply-To: <4A269364.2080304-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday 03 June 2009 11:14:44 Steve Dickson wrote:
> Mike Frysinger wrote:
> > the libtirpc package is self described as a "standalone package".  i
> > wonder how far that actually goes.  wrt NIS, it requires the system C
> > library to provide NIS functionality or you get a build failure in a few
> > files.  would be nice if libtirpc were usable without any NIS baggage at
> > all.
>
> NIS used RPC procedures to communicate. As it stands today
> NIS is currently using the RPC procedures glibc. In the
> future there is a very good chance that NIS will start
> using the RPC procedures in libtirpc especially if
> IPV6 support is needed...
>
> So I'm a bit confused on what you mean by "NIS baggage"
> in the libtirpc package.

you cannot build libtirpc on a system that doesnt provide NIS functionality.  
realistic RPC usage today is NFS related services only (i.e. a NFS client 
mounting a share on a NFS server).  i might be missing something (since i'm no 
RPC/NIS expert), but if this scenario doesnt require NIS in any way, then 
having libtirpc require/use it is bloat that should have an option to disable.
-mike
