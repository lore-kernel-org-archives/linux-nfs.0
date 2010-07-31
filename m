Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51449 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792Ab0GaTEW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Jul 2010 15:04:22 -0400
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Phil Pishioneri <pgp@psu.edu>, Volker.Lendecke@SerNet.DE,
        Jeremy Allison <jra@samba.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
In-Reply-To: <09B770A6-48DB-4296-B6C2-BF46D4DC7E57@dilger.ca>
References: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	 <20100722162712.GB10352@jeremy-laptop>
	 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	 <1279817930.3621.14.camel@heimdal.trondhjem.org>
	 <20100722180204.GA32008@samba1> <E1Oc08W-00CZuz-Ns@intern.SerNet.DE>
	 <1279825160.3621.71.camel@heimdal.trondhjem.org> <4C5311F4.2050100@psu.edu>
	 <1280513506.12852.22.camel@heimdal.trondhjem.org>
	 <09B770A6-48DB-4296-B6C2-BF46D4DC7E57@dilger.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 31 Jul 2010 15:03:52 -0400
Message-ID: <1280603032.3125.24.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-07-31 at 12:41 -0600, Andreas Dilger wrote:
> On 2010-07-30, at 12:11, Trond Myklebust wrote:
> > Your Mac has a perfectly functional CIFS client, as do your Linux boxes.
> > They both interoperate just fine with Samba, and would presumably
> > continue to do so if someone were to decide to reuse the ctime field on
> > your Samba box as storage for a create time.
> 
> CIFS doesn't support symlinks (they just appear as the referenced file), so I've had applications that scan the filesystem recurse indefinitely due to symlinked directories on a CIFS share appearing as hard-linked directories on the client.  This doesn't happen when the filesystem is accessed via NFS.

Sigh... So please explain how it would be useful to export that
particular filesystem through _both_ CIFS and NFS?

My point was that in most circumstances you want to export either
through CIFS or through NFS, but very rarely both.

I also made the point that converting ctime into a creation time would
break NFS, but it would be a limited breakage, mainly affecting the
client's ability to detect ACL changes, and possibly causing the inode
to get temporarily updated with stale attribute information on occasion
due to out-of-order RPC replies.

  Trond

