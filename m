From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: asynchronous locks for cluster exports
Date: Fri, 15 Dec 2006 14:51:51 -0500
Message-ID: <20061215195151.GH30858@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <11653832602203-git-send-email-bfields@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Dec 06, 2006 at 12:34:10AM -0500, J. Bruce Fields wrote:
> We'd like an asynchronous posix locking interface so that we can provide NFS
> clients with cluster-coherent locking without blocking lockd while the
> filesystem goes off and talks to other nodes.
> 
> So, here's one attempt.  It also includes an draft implementation of the
> filesystem side for GFS2, which may well be wrong--it's not even tested
> yet--but hopefully gives some idea what would be necessary.

By the way, I'm keeping updated versions of this patch series in the
server-cluster-locking-api branch of the repository at
git://linux-nfs.org/~bfields/linux.git.

So if you already have a git tree sitting around (cloned with something
like "git clone
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git")

They you should be able to get this with

	git fetch git://linux-nfs.org/~bfields/linux.git +server-cluster-locking-api:server-cluster-locking-api
	git checkout server-cluster-locking-api

Alternatively you can browse the patches without git from

	http://linux-nfs.org/cgi-bin/gitweb.cgi?p=bfields-2.6.git;a=shortlog;h=server-cluster-locking-api

--b.
