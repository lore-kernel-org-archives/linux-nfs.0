From: "NeilBrown" <neilb@suse.de>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 26 Mar 2008 08:38:22 +1100 (EST)
Message-ID: <34178.192.168.1.70.1206481102.squirrel@neil.brown.name>
References: <47CF62C5.7000908@m2000.com>
    <18384.50909.866848.966192@notabene.brown>
    <9a8748490803121513w285cd45rb6b26a3d842cac1b@mail.gmail.com>
    <20080312221511.GC31632@fieldses.org>
    <9a8748490803121516u36395872i70cc88b0439adc74@mail.gmail.com>
    <18394.1501.991087.80264@notabene.brown> <47DAEFD0.9020407@m2000.com>
    <47E92F8E.7030504@m2000.com> <20080325190943.GF2237@fieldses.org>
    <32953.192.168.1.70.1206477121.squirrel@neil.brown.name>
    <20080325212425.GA20257@josefsipek.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>, xfs@oss.sgi.com,
	"Adam Schrotenboer" <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	"Jesper Juhl" <jesper.juhl@gmail.com>,
	"Trond Myklebust" <trond.myklebust@netapp.com>,
	lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	"Thomas Daniel" <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	"Frederic Revenu" <frevenu-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	"Jeff Doan" <jdoan-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: "Josef 'Jeff' Sipek" <jeffpc-PM1Ls4bqFqUFEYicpp4bmg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:42515 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760576AbYCYVie (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2008 17:38:34 -0400
In-Reply-To: <20080325212425.GA20257-PM1Ls4bqFqUFEYicpp4bmg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, March 26, 2008 8:24 am, Josef 'Jeff' Sipek wrote:

> Unless you specify the "ikeep" mount option, XFS will remove unused inode
> clusters.  The newly freed blocks can be then used to store data or
> possibly
> a new inode cluster.  If the blocks get reused for inodes, you'll end up
> with inodes whose generation numbers regressed. (inode number = f(block
> number))
>
> Using the "ikeep" mount option causes to _never_ free empty inode
> clusters.
> This means that if you create many files and then unlink them, you'll end
> up
> with many unused inodes that are still allocated (and taking up disk
> space)
> but free to be used by the next creat(2)/mkdir(2)/etc..
>
> This "problem" is inherent to any file system which dynamically allocates
> inodes.

Yes, I understand all that.

However you still need to do something about the generation number.  It
must be set to something.

When you allocate an inode that doesn't currently exist on the device,
you obviously cannot increment the old value and use that.
However you can do a lot better than always using 0.

The simplest would be to generate a 'random' number (get_random_bytes).
Slightly better would be to generate a random number at boot time
and use that, incrementing it each time it is used to set the
generation number for an inode.

Even better would be store store that 'next generation number' in the
superblock so there would be even less risk of the 'random' generation
producing repeats.
This is what ext3 does.  It doesn't dynamically allocate inodes,
but it doesn't want to pay the cost of reading an old inode from
storage just to see what the generation number is.  So it has
a number in the superblock which is incremented on each inode allocation
and is used as the generation number.

Certainly anything would be better than always using the same number.

NeilBrown

