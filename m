Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753101Ab1IWKec (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 06:34:32 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1316747758.3346.89.camel@perseus.themaw.net>
References: <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com> <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com> <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org> <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com> <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com> 
To: miklos@szeredi.hu, Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Date: Fri, 23 Sep 2011 11:33:45 +0100
Message-ID: <21772.1316774025@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Ian Kent <raven@themaw.net> wrote:

> But the other users of the vfs-automount didn't behave this way before
> the vfs-automount changes.

That's a very good point.  Prior to my d_automount() patches, NFS, AFS and, I
think, CIFS used strict symlink rules for when to automount because the
automounting was done by a directory with a ->follow_link() op.  Therefore,
stat() automounted and lstat() didn't.

Autofs, on the other hand took care to suppress automounting on stat() too.

My d_automount() patches had two purposes, in order of importance:

 (1) Simplify the automount procedure in the kernel by giving it formal VFS
     support, and thus getting rid of directories with follow_link() ops.

 (2) Make the automount semantics consistent.

So my original patches are somewhat at fault here.  I broke autofs's handling
of stat(), getxattr() and kept that of NFS, AFS and CIFS.  Miklos's patch
simply flips the regression the other way.

The only fault I've had reported against my original patches in this respect is
with ls, and that's fixed in userspace upstream now (libacl was using getxattr
when it should've been using lgetxattr).  It has been mentioned that nautilus
(I think it was) may also broken - which makes sense as it's a file manager.

The only fault I've had reported against Miklos's patch is the NFS4 pathwalk
during mount.

Having thought it over some more, I'm leaning towards reverting Miklos's patch,
removing the do we/don't we logic from follow_automount() (or simplifying it)
and having the syscalls suppy the LOOKUP_NO_AUTOMOUNT flag as appropriate -
whatever is meant by 'appropriate'.

I'm also okay with requiring userspace to be fixed up, but I can also see the
arguments against that.

David
