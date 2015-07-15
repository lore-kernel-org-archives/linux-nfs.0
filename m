Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54985 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905AbbGOXkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2015 19:40:55 -0400
Date: Thu, 16 Jul 2015 09:40:46 +1000
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150716094046.445c038b@noble>
In-Reply-To: <20150715210756.GE21669@fieldses.org>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150715210756.GE21669@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 15 Jul 2015 17:07:56 -0400 "J. Bruce Fields"
<bfields@fieldses.org> wrote:

> > Wow.... this is turning out to be a lot more complex that I imagined at
> > first (isn't that always the way!).
> > 
> > There is a lot of good stuff here, but I think we can probably make it
> > simpler and so even better.
> 
> I'm still not convinced that the expkey should have a dentry reference
> in the key in the first place.  Fixing that would fix the immediate
> problem.

???  If we removed the dentry, how would you export a subdirectory of a
filesystem?

NeilBrown


> 
> (Though it might still be useful to have a way to do stuff on umount of
> an exported filesystem.)
> 
> --b.
> 
