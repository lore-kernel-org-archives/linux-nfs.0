From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: implement option checking when remounting NFS
	filesystems
Date: Fri, 11 Apr 2008 15:32:27 -0400
Message-ID: <1207942347.14621.1.camel@heimdal.trondhjem.org>
References: <1207937413-16189-1-git-send-email-jlayton@redhat.com>
	<47FFB9B3.1020703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47FFB9B3.1020703@redhat.com>
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


On Fri, 2008-04-11 at 15:19 -0400, Peter Staubach wrote:
> Jeff Layton wrote:
> > When remounting an NFS or NFS4 filesystem, the new NFS options are not
> > respected, yet the remount will still return success. This patch adds
> > a remount_fs sb op for NFS that checks any new nfs mount options against
> > the existing ones and fails the mount if any have changed.
> >
> > This is only implemented for string-based mount options since doing
> > this with binary options isn't really feasible.
> 
> What about respecting the new options as makes sense and rejecting
> those which absolutely can't be changed dynamically?

If we were to do this, then how should superblocks that are shared
between multiple mountpoints behave?

Cheers
  Trond
