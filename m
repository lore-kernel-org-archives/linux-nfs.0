Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754727Ab1IWPYJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 11:24:09 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <29743.1316791138@redhat.com>
References: <29743.1316791138@redhat.com> <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com> <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com> <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com> <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org> <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com> <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com> <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org> 
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        miklos@szeredi.hu, Jeff Layton <jlayton@redhat.com>,
        viro@zeniv.linux.org.uk, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Date: Fri, 23 Sep 2011 16:23:18 +0100
Message-ID: <29833.1316791398@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

David Howells <dhowells@redhat.com> wrote:

> Can we at least move the automount/no automount logic out of
> follow_automount() and into the path walk callers?  That way
> follow_automount() becomes more robust and we're less likely to get bitten in
> future as we can define the behaviour more precisely.

On the other hand, if we do that, it reduces our ability to control things on
a per-filesystem basis:-/

David
