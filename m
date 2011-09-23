Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65015 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424Ab1IWQTu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 12:19:50 -0400
Received: by fxe4 with SMTP id 4so3971289fxe.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 09:19:49 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Ian Kent <raven@themaw.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        viro@zeniv.linux.org.uk, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
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
	<1316788444.14812.10.camel@lade.trondhjem.org>
	<CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
	<1316792468.3346.144.camel@perseus.themaw.net>
Date: Fri, 23 Sep 2011 18:19:20 +0200
In-Reply-To: <1316792468.3346.144.camel@perseus.themaw.net> (Ian Kent's
	message of "Fri, 23 Sep 2011 23:41:08 +0800")
Message-ID: <87d3ertenr.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ian Kent <raven@themaw.net> writes:

> On Fri, 2011-09-23 at 07:46 -0700, Linus Torvalds wrote:
> We haven't had any non-trivial problems reported that I know about. As
> I've said before the problem Miklos referred to was an inconsistency in
> user space which the new automount code exposed, and a change has been
> accepted to fix it and this was done prior to Miklos posting his patch. 
>
> My point is that, since we haven't had any non-trivial problems reported
> due to the semantic change, in what six months or more, why change it
> now?

Six month is a short time in terms of kernel deployment.  It's entirely
possible that many installations with large maps simply haven't yet
upgraded their kernel.

And ordering WRT userspace package upgrades doesn't work on such time
scales either.  It's entirely possible that a distribution will upgrade
their kernel yet pick an older userspace package.

Also, there are file managers out there that haven't yet been fixed that
are known to trigger the bad behavior.  So I don't believe your
arguments justify leaving things as they are.

Thanks,
Miklos
