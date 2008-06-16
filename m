From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Mon, 16 Jun 2008 12:54:46 -0400
Message-ID: <1213635286.7238.13.camel@localhost>
References: <20080613213759.26929.patches@notabene>
	 <1080613114215.27095@suse.de> <48565F19.10508@redhat.com>
	 <76bd70e30806160809o495dd50fw88a80ec0673c0dc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>, NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756189AbYFPQzM@vger.kernel.org>
In-Reply-To: <76bd70e30806160809o495dd50fw88a80ec0673c0dc1@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-06-16 at 11:09 -0400, Chuck Lever wrote:

> I think an error reply is much better than no reply in nearly every
> case.  NFS3ERR_JUKEBOX/NFS4ERR_DELAY is an interesting idea, but
> something else again will probably be required for v4.1 with sessions.

NFS3ERR_JUKEBOX/NFS4ERR_DELAY may be inappropriate if the nfs daemon has
already started handling the RPC call, since you may be interrupting a
non-idempotent operation.

The only complete solution to this problem is NFSv4.1 with persistent
sessions.

Cheers
  Trond
