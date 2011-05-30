Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:58998 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752054Ab1E3MnD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 May 2011 08:43:03 -0400
From: Ruediger Meier <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: infinite getdents64 loop
Date: Mon, 30 May 2011 14:42:58 +0200
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <20110530075930.134c7541@corrin.poochiereds.net>
In-Reply-To: <20110530075930.134c7541@corrin.poochiereds.net>
Content-Type: text/plain;
  charset="iso-8859-1"
Message-Id: <201105301442.58997.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Monday 30 May 2011, Jeff Layton wrote:
> On Mon, 30 May 2011 11:37:01 +0200
> Ruediger Meier <sweet_f_a@gmx.de> wrote:
> > On Sunday 29 May 2011, Trond Myklebust wrote:
> > > It's actually a problem with the underlying filesystem: it is
> > > generating readdir 'offsets' that are not unique. In other words,
> > > if
> >
> > Does this mean ext4 generally does not work with for nfs?
>
> Does it help if you turn off the dir_index feature on the filesystem?
> See the tune2fs(8) manpage for how to do that.

Unfortunately I can't umount it allthough I did exportfs -u and lsof 
doesn't show used files. (reboot not possible right now)

Hopefully I can try it until tomorrow on the other machine (have to wait 
for some jobs finished).

Pity that I am not able to create such a broken ext4/nfs server from 
scratch on a test machine. Seems I get it broken only if it was 
maltreated by our users some time in production.


cu,
Rudi
