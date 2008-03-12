From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 12 Mar 2008 23:13:23 +0100
Message-ID: <9a8748490803121513w285cd45rb6b26a3d842cac1b@mail.gmail.com>
References: <47CF0829.4020502@m2000.com>
	 <1204752463.5035.34.camel@heimdal.trondhjem.org>
	 <47CF157B.1010908@m2000.com>
	 <18383.24847.381754.517731@notabene.brown>
	 <47CF62C5.7000908@m2000.com>
	 <18384.50909.866848.966192@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Adam Schrotenboer" <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>,
	lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	"Thomas Daniel" <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:35894 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755119AbYCLWN2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2008 18:13:28 -0400
Received: by el-out-1112.google.com with SMTP id v27so2030649ele.17
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2008 15:13:27 -0700 (PDT)
In-Reply-To: <18384.50909.866848.966192-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/03/2008, Neil Brown <neilb@suse.de> wrote:
> On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
>  > Neil Brown wrote:
>  > > On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
>  > >
>  > > Where :-)
>  > >
>  > > A excerpt from the logs to show actual error messages could be
>  > > helpful.
>  > >
>  > > Thanks,
>  > > NeilBrown
>  > sorry, must have missed the paste
>  >
>  > Feb 28 17:27:58 koi kernel: nfs_update_inode: inode 3221350147 mode
>  > changed, 0040755 to 0100644
>  > Feb 28 21:57:22 koi kernel: nfs_update_inode: inode 2149056279 mode
>  > changed, 0040755 to 0100755
>  > Mar  5 01:43:21 koi kernel: nfs_update_inode: inode 3222473680 mode
>  > changed, 0040755 to 0100644
>  > Mar  5 08:52:19 koi kernel: nfs_update_inode: inode 3222473568 mode
>  > changed, 0120777 to 0100644
>  > Mar  5 15:00:01 koi kernel: nfs_update_inode: inode 3222473569 mode
>  > changed, 0120777 to 0100644
>  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473674 mode
>  > changed, 0120777 to 0100644
>  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473675 mode
>  > changed, 0120777 to 0100644
>  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473672 mode
>  > changed, 0040755 to 0100644
>  > Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473673 mode
>  > changed, 0120777 to 0100644
>  >
>  >
>
> Hmmm...
>  Directories and symlinks "changing" to regular files.
>
>  32bit inode numbers with the high bit set.
>
>  Random times, but a burst at 3pm one afternoon.
>
>  The fact that it happens so rarely make is very hard to collect more
>  data....
>

I've reported this problem in the past for 2.6.13.4, so it's not a new problem.
Happens very rarely indeed.
See http://lkml.org/lkml/2007/2/26/102 and
http://lkml.org/lkml/2007/3/1/53 for details.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
