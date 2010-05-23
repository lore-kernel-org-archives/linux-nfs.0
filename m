Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52135 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368Ab0EWWMG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 May 2010 18:12:06 -0400
Date: Mon, 24 May 2010 08:11:55 +1000
From: Neil Brown <neilb@suse.de>
To: hce <webmail.hce@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS cache
Message-ID: <20100524081155.03046681@notabene.brown>
In-Reply-To: <AANLkTilYaqsm-Yp-LKaB2H0lTxm6_YjKwEJ2AVEn4wJt@mail.gmail.com>
References: <AANLkTikZfdnCMm0TkEaVnN2kqVzMZ7CYmbe1YengmRMY@mail.gmail.com>
	<AANLkTilYaqsm-Yp-LKaB2H0lTxm6_YjKwEJ2AVEn4wJt@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 17 May 2010 09:54:12 +1000
hce <webmail.hce@gmail.com> wrote:

> On Sun, May 16, 2010 at 6:26 PM, hce <webmail.hce@gmail.com> wrote:
> > Hi,
> >
> > I posted following message on list, but did not see it on list, sorry
> > if it is duplicated.
> >
> > I have an application to use NFS over FUSE, if I keep typing "ls" in
> > the same directory, the client NFS only sent GETATT, no more READDIR,
> > all directory contents displayed on screen came from NFS cache. That
> > caused many problems and I'd like to disable NFS client cache. But it
> > did not work when I add "-o noac" option to mount.
> 
> I've just realised that the noac is only for NFS attribute cache, so
> add "-o noac" only generates more getatt for up paths, the "readdir"
> was still not called if I keep typing "ls" in the same directory.
> 
> Does NFS has another cache for directory structure as well? It seems
> it displayed directory contents on the screen from cache as it did not
> call readdir to FUSe.

(almost) all linux filesystems use the 'page cache' for storing parts or all
of files and directories.
Linux/NFS uses the page cache to store the contents of a directory.  It will
normally only refresh the cached directory when the 'mtime' or the 'ctime' of
the directory (as reported by GETATTR) changes.

If FUSE ensures that the mtime changes whenever the directory content changes
you should get the same cache behaviour as with regular nfs filesystems.
If FUSE does not update the mtime, then it will not work reliably with NFS.

NeilBrown


> 
> > Also I don't want
> > NFS GETATT retransmission during file copy. Appreciate your advice and
> > sample examples for how to mount nfs to disable client cache and
> > retransmission.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

