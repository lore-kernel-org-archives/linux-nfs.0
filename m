Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761Ab1IWQzg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:55:36 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFzgqrtwgH1j0i-XH0kDwicLWPCA=1W57gjy9EP23k4Ffw@mail.gmail.com>
References: <CA+55aFzgqrtwgH1j0i-XH0kDwicLWPCA=1W57gjy9EP23k4Ffw@mail.gmail.com> <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com> <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com> <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org> <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com> <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com> <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org> <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com> <1316792468.3346.144.camel@perseus.themaw.net> <CA+55aFx03u51bbAPe_o=4PeyE0dFnuL1KyqRdTJCFUD-vM6V-w@mail.gmail.com> <13920.1316796007@redhat.com!
 >
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, Ian Kent <raven@themaw.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, miklos@szeredi.hu,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Date: Fri, 23 Sep 2011 17:54:49 +0100
Message-ID: <14156.1316796889@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> > getxattr and co. are trickier because they don't have an AT_ flags form, and
> > it can be argued that these, lgetxattr and co. included should automount.
> > However, that would seriously upset ls, so I think we have to leave lgetxattr
> > not automounting, and so getxattr should follow.
> 
> Why?
> 
> If you really want to follow, use the '/' at the end.

Sorry, 'follow' as in follow what lgetxattr does, not 'follow' as in
automount.  Bad choise of verb.

David
