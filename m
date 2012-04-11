Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346Ab2DKSUR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 14:20:17 -0400
Date: Wed, 11 Apr 2012 14:20:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120411182015.GA31025@fieldses.org>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
 <4F841D2A.9020504@parallels.com>
 <20120410081612.65dd25fa@tlielax.poochiereds.net>
 <4F842BAE.2010804@parallels.com>
 <20120410202251.GH18465@fieldses.org>
 <4F855E3D.6090306@parallels.com>
 <20120411172019.GB29903@fieldses.org>
 <4F85C087.7060106@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F85C087.7060106@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 11, 2012 at 09:33:59PM +0400, Stanislav Kinsbursky wrote:
> 11.04.2012 21:20, J. Bruce Fields пишет:
> >So you really are exporting subtrees of the same filesystem from
> >multiple containers?  Why?
> >
> 
> Everything is very-very simple and obvious.
> We use "chroot jail". This is the most often and simple setup for containers.
> And, basicaly, Virtuozzo container file system consist of two parts:
> one of them is it's private modified data, another part is a
> template, used for all containers based on it (rhel6, for example;
> when it's content is modified my some container - then modified file
> copied to private part of container, which modified the file).
> Anyway, with properly configured environment it could be as many
> containers on the same file system, as possible. And making sure,
> that no data shared between them is root's responsibility.
> This approach gives us journal bottleneck. That's why, in future we
> are going to use "ploop" device (a kind of a very smart loop device)
> per container. And thus this problem with grace period for file
> systems will disappear.
> 
> >And are you sure you're not vulnerable to filehandle-guessing attacks?
> >
> 
> No, I'm not. Could you give me some examples of such attacks?

Suppose you export subtree /export/foo of filesystem /export to a
client, that client can also easily access anything else in /export; all
it hsa to do is guess the filehandle of the thing it wants to access (or
just guess filehandle of /export itself; root filehandles are likely
especially easily to guess), and then work from there.

(There's a workaround: you can set the subtree_check option.  That
causes a number of problems (renaming a file to a different directory
changes its filehandle, for example, so anyone trying to use it while it
gets renamed gets an unexpected ESTALE).  So we don't recommend it.)

So if all the containers are sharing the same filesystem, then anyone
exporting a subdirectory of its own filesystem has essentially granted
access to everyone's filesystem.

For that reason it's really only recommended to export separate
filesystems....

--b.
