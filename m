Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757533Ab0FIKl4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jun 2010 06:41:56 -0400
Date: Wed, 9 Jun 2010 06:43:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] nfsd: fix error handling in write_ports interfaces
Message-ID: <20100609064343.1f448bf2@corrin.poochiereds.net>
In-Reply-To: <20100609000002.GL26435@fieldses.org>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
	<20100609000002.GL26435@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 8 Jun 2010 20:00:03 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 07, 2010 at 11:33:17AM -0400, Jeff Layton wrote:
> > This patchset fixes some problems with refcounting when there are
> > problems starting up nfsd. The easiest way to reproduce this is to have
> > rpcbind down and then try to start nfsd. The write_ports calls will
> > generally return failure at that point due to the fact that lockd can't
> > register its ports. That leaves the nfsd_serv pointer set, with the
> > sv_threads count set at 0. The first two patches fix this problem.
> 
> Does this look like it's always been a problem, or was it introduced by
> recent changes?
> 
> (Just a question of priority and whether it should be fixed in -stable
> branches too.)
> 

I think it's a long-standing bug -- at least since 2006 or so when the
portlist file was added, but some recent changes made it easier to hit.

Our QA group has a test where they restart both the nfs "service" and
rpcbind. With the recent change to using TCP to do rpcbind
registrations, the kernel now can hold open a socket to rpcbind for a
little while after doing the registration.

If you restart rpcbind within that window, it can fail to bind to port
111 as it didn't use SO_REUSEADDR. I recently proposed a patch to
rpcbind to fix that:

http://sourceforge.net/mailarchive/forum.php?thread_name=1275575657-9666-1-git-send-email-jlayton%40redhat.com&forum_name=libtirpc-devel

...portmap has a similar bug, but I haven't gotten around to fixing it
there yet.

Due to that problem, our QA group ended up trying to start nfsd with
rpcbind non-functional. When they got rpcbind to start, then they still
couldn't bring up nfsd immediately since nfsd_serv had already been
created and write_versions failed. 

IMO, this set probably isn't stable material. It's a nuisance, but the
simple workaround is to just run "rpc.nfsd 0" and then you can start up
nfsd.

-- 
Jeff Layton <jlayton@redhat.com>
