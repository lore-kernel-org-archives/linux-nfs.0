From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: implement option checking when remounting NFS
	filesystems
Date: Fri, 11 Apr 2008 15:47:21 -0400
Message-ID: <20080411154721.7e6413c1@tleilax.poochiereds.net>
References: <1207937413-16189-1-git-send-email-jlayton@redhat.com>
	<47FFB9B3.1020703@redhat.com>
	<1207942347.14621.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207942347.14621.1.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 Apr 2008 15:32:27 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Fri, 2008-04-11 at 15:19 -0400, Peter Staubach wrote:
> > Jeff Layton wrote:
> > > When remounting an NFS or NFS4 filesystem, the new NFS options are not
> > > respected, yet the remount will still return success. This patch adds
> > > a remount_fs sb op for NFS that checks any new nfs mount options against
> > > the existing ones and fails the mount if any have changed.
> > >
> > > This is only implemented for string-based mount options since doing
> > > this with binary options isn't really feasible.
> > 
> > What about respecting the new options as makes sense and rejecting
> > those which absolutely can't be changed dynamically?
> 
> If we were to do this, then how should superblocks that are shared
> between multiple mountpoints behave?
> 

I was thinking the same thing and it occurs to me that that's an
existing bug that's not addressed by this patch. Right now, if you have
2 mounts that share a superblock, you can remount one with 'ro' and
*both* will end up being 'ro'.

I think I need to add a check for the sb reference count and return
-EBUSY or something if the sb is shared.

But, back to Peter's question...

In the case of a non-shared superblock, there aren't many options that
I can see that we can just apply. Some of the flags might be doable,
along with some of the ac* settings.

Changing the rsize/wsize means doing a fsinfo call, I think. The timeo
and retries are also tricky. If you have 2 separate sb's sharing a
nfs_client, then you have to be careful.

If we want to do that, then we certainly can consider it in the future,
this patch (with a check for shared sb's) should give us a starting
point if we want to do that.

-- 
Jeff Layton <jlayton@redhat.com>
