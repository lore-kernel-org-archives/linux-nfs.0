Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36640 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761006Ab2DKTjL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2012 15:39:11 -0400
Message-ID: <4F85DDDD.5020702@parallels.com>
Date: Wed, 11 Apr 2012 23:39:09 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com> <4F841D2A.9020504@parallels.com> <20120410081612.65dd25fa@tlielax.poochiereds.net> <4F842BAE.2010804@parallels.com> <20120410202251.GH18465@fieldses.org> <4F855E3D.6090306@parallels.com> <20120411172019.GB29903@fieldses.org> <4F85C087.7060106@parallels.com> <20120411182015.GA31025@fieldses.org>
In-Reply-To: <20120411182015.GA31025@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.04.2012 22:20, J. Bruce Fields написал:
> Suppose you export subtree /export/foo of filesystem /export to a
> client, that client can also easily access anything else in /export; all
> it hsa to do is guess the filehandle of the thing it wants to access (or
> just guess filehandle of /export itself; root filehandles are likely
> especially easily to guess), and then work from there.

I see.
So, if I undertand you correctly, filesystem to export should be not 
only one per server, but also should not consist or any other files, 
which are not allowed to export.
Currently, in OpenVZ we have kernel threads per container. Thus even 
kernel threads are in "chroot jail".
But I'll check, do we have such vulnerability.
Thank you.

> (There's a workaround: you can set the subtree_check option.  That
> causes a number of problems (renaming a file to a different directory
> changes its filehandle, for example, so anyone trying to use it while it
> gets renamed gets an unexpected ESTALE).  So we don't recommend it.)
>
> So if all the containers are sharing the same filesystem, then anyone
> exporting a subdirectory of its own filesystem has essentially granted
> access to everyone's filesystem.
>
> For that reason it's really only recommended to export separate
> filesystems....

Thanks. Anyway, we are going to get rid of "chroot jails" and replace 
them by separated loop device.

