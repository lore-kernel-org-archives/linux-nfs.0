From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Secure user authentication for NFS using RPCSEC_GSS [0/6]
Date: Sun, 12 Jan 2003 21:19:51 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030113021951.GE18756@gtf.org>
References: <15906.1154.649765.791797@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@transmeta.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15906.1154.649765.791797@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

On Mon, Jan 13, 2003 at 01:12:50AM +0100, Trond Myklebust wrote:
> Our wish is to provide basic kernel RPC client support for the generic
> RPCSEC_GSS protocol, and for communicating with a userland daemon that
> does the actual the security context negotiation with the RPC server.
> Communication between kernel and userland is done over a set of named
> pipes (in much the same way as the CODA upcall/downcall is done) in a
> private ramfs-like filesystem.

Well, AFS also wants Kerb [but a weird Kerb4 variant IIRC], but,
OTOH why not do all this authentication and stuff in userspace?

Several other projects through the years have done similar things, where
a userspace daemon handles auth and such, and then passes an fd into
the kernel via ioctl [or write(2)ing fd value to a mini-ramfs VFS node].
