Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2835 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730Ab1ITXFE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 19:05:04 -0400
Subject: Re: Please support NSF squashing multiple groups
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: paul.szabo@sydney.edu.au
Cc: linux-nfs@vger.kernel.org
Date: Tue, 20 Sep 2011 19:05:03 -0400
In-Reply-To: <201109202248.p8KMmLaI008501@bari.maths.usyd.edu.au>
References: <201109202248.p8KMmLaI008501@bari.maths.usyd.edu.au>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1316559903.15093.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-09-21 at 08:48 +1000, paul.szabo@sydney.edu.au wrote: 
> Dear all,
> 
> I wrote about some security issues with NFS, about protecting against
> privileged UIDs and GIDs, like root_squash protects against root.
> 
> Your advice was to use NFSv4 with kerberos authentication. I now
> succeeded in setting that up on a test system; though not as simple as
> should be, it seems to work as expected. The changes required for use
> are non-trivial, so I will not immediately be able to use it.
> 
> Seems that the mountd option --manage-gids handles the secondary groups
> only. I still do not quite understand why mountd (with that or another
> option) cannot handle the primary GID also, setting it to the GID
> corresponding to the UID on the server; and maybe even "squash" any UIDs
> in a table similar to idmap, or simply squash UIDs less than UID_MIN
> (squash directly, without any kernel interaction). Could you please tell
> me whether those are conceptually possible?

Secondary groups are all about granting permission to perform certain
operations that are restricted to users of that group.

The _primary_ group is about the above _plus_ it has a role when you are
creating new objects, where it defines the 'group' owner of that object.
Your proposal would screw up utilities which call the 'setgid()' or
'setfsgid()' functions before creating files or directories that need to
have very specific group ownerships.

IOW: what you are proposing is a potential security problem.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

