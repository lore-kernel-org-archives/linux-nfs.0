Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21762 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422Ab1IWOeX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 10:34:23 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Howells <dhowells@redhat.com>
Cc: miklos@szeredi.hu, Linus Torvalds <torvalds@linux-foundation.org>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 10:34:04 -0400
In-Reply-To: <21772.1316774025@redhat.com>
References: <1316747758.3346.89.camel@perseus.themaw.net>
	 <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
	 <1316707443.3346.44.camel@perseus.themaw.net>
	 <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
	 <1316709935.3346.48.camel@perseus.themaw.net>
	 <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
	 <20110922144453.6cf53a25@barsoom.rdu.redhat.com>
	 <1316719228.3968.14.camel@lade.trondhjem.org>
	 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
	 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
	  <21772.1316774025@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1316788444.14812.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-23 at 11:33 +0100, David Howells wrote: 
> The only fault I've had reported against my original patches in this respect is
> with ls, and that's fixed in userspace upstream now (libacl was using getxattr
> when it should've been using lgetxattr).  It has been mentioned that nautilus
> (I think it was) may also broken - which makes sense as it's a file manager.
> 
> The only fault I've had reported against Miklos's patch is the NFS4 pathwalk
> during mount.

If NFSv4 is the only concern, then Linus's solution is easily
implementable. I don't have any problems with adding a LOOKUP_DIRECTORY
flag to the NFSv4 mount path lookup call.

My objections are due to the other cases that I pointed out, where
Miklos's patch introduced changes in behaviour that IMO are unnecessary
and incorrect.

> Having thought it over some more, I'm leaning towards reverting Miklos's patch,
> removing the do we/don't we logic from follow_automount() (or simplifying it)
> and having the syscalls suppy the LOOKUP_NO_AUTOMOUNT flag as appropriate -
> whatever is meant by 'appropriate'.

I agree. That means the default behaviour is the correct one and we're
only adding exceptions in cases where exposing the hidden directory is
acceptable either to address an optimisation concern or an application
regression.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

