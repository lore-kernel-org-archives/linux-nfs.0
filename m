Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:45348 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbaLSLJq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 06:09:46 -0500
Received: by mail-qa0-f47.google.com with SMTP id n4so456470qaq.34
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 03:09:46 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 19 Dec 2014 06:09:42 -0500
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs
 race
Message-ID: <20141219060942.2bf613c2@tlielax.poochiereds.net>
In-Reply-To: <6944.1418957186@jrobl>
References: <20141217195911.GF9617@fieldses.org>
	<20141217200153.GG9617@fieldses.org>
	<12689.1418917838@jrobl>
	<20141218155838.GD18179@fieldses.org>
	<13170.1418920034@jrobl>
	<20141218231548.GF15665@dastard>
	<6944.1418957186@jrobl>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Dec 2014 11:46:26 +0900
"J. R. Okajima" <hooanon05g@gmail.com> wrote:

> 
> Dave Chinner:
> > We use file handles on local filesystems. They have exactly the same
> > semantics as NFS file handles and so local filesystems have the same
> > ESTALE exposure as "distributed" filesystems to this problem. i.e:
> 
> It is reasonable.
> But do you think ESTALE is good in case of __d_unalias()?
> 

I don't think you'll ever see __d_unalias called on a local fs, as the
__d_find_any_alias call should always return NULL on a local fs.

With a local fs, we always know that the dcache is correct (which is
why local fs' generally don't supply a d_revalidate method). The only
way to get to __d_unalias is for all of the following to be true:

- you're splicing a new dentry into the tree
- that new dentry is a directory
- the inode for it already has a dentry associated with it that's in a
  different place

...that can only happen in a remote filesystem. The only way for that
to occur on a local fs is for that fs to allow a directory to be
hardlinked, which should of course never happen.

As to whether ESTALE is as good as EBUSY there...I doubt it'll matter
much. Remote filesystems generally have to be able to cope with ESTALE
errors anyway, and I doubt a lot of userland code handles EBUSY
especially for this situation.

-- 
Jeff Layton <jlayton@primarydata.com>
