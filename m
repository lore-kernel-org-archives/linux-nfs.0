Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:36917 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755793Ab2AIWXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 17:23:19 -0500
From: Wolfgang Walter <wolfgang.walter@stwm.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes and cleanups
Date: Mon, 9 Jan 2012 23:15:27 +0100
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <1326142671.9041.1.camel@lade.trondhjem.org>
In-Reply-To: <1326142671.9041.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201201092315.28230.wolfgang.walter@stwm.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 09 January 2012, Trond Myklebust wrote:
> Hi Linus,
> 
> Please pull from the "nfs-for-3.3" branch of the repository at
> 
>    git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-
for-3.3
> 
> This will update the following files through the appended changesets.
> 
>   Cheers,
>     Trond
> 
> 
> commit 074b1d12fe2500d7d453902f9266e6674b30d84c
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Jan 9 13:46:26 2012 -0500
> 
>     NFSv4: Change the default setting of the nfs4_disable_idmapping 
parameter
>     
>     Now that the use of numeric uids/gids is officially sanctioned in
>     RFC3530bis, it is time to change the default here to 'enabled'.
>     
>     By doing so, we ensure that NFSv4 copies the behaviour of NFSv3 when 
we're
>     using the default AUTH_SYS authentication (i.e. when the client uses the
>     numeric uids/gids as authentication tokens), so that when new files are
>     created, they will appear to have the correct user/group.
>     It also fixes a number of backward compatibility issues when migrating
>     from NFSv3 to NFSv4 on a platform where the server uses different 
uid/gid
>     mappings than the client.
>     
>     Note also that this setting has been successfully tested against servers
>     that do not support numeric uids/gids at several Connectathon/Bakeathon
>     events at this point, and the fall back to using string names/groups has
>     been shown to work well in all those test cases.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 


Does this mean that one has to modify all one's clients to get the old 
behaviour?

I'm not sure if this is a really good idea. I don't see the advantage. This 
will break a lot of existing installations when upgrading to >=3.3. And 
someone migrating from NFSv3 to NFSv4 has to give some thoughts to it anyway.


Regards,
-- 
Wolfgang Walter
Studentenwerk München
Anstalt des öffentlichen Rechts
