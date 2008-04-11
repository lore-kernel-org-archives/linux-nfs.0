From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: implement option checking when remounting NFS
	filesystems
Date: Fri, 11 Apr 2008 15:05:06 -0400
Message-ID: <20080411150506.7fa36199@tleilax.poochiereds.net>
References: <1207937413-16189-1-git-send-email-jlayton@redhat.com>
	<47FFB58D.6080902@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: chuck.lever@oracle.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47FFB58D.6080902@oracle.com>
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

On Fri, 11 Apr 2008 15:01:33 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Jeff Layton wrote:
> > When remounting an NFS or NFS4 filesystem, the new NFS options are not
> > respected, yet the remount will still return success. This patch adds
> > a remount_fs sb op for NFS that checks any new nfs mount options against
> > the existing ones and fails the mount if any have changed.
> > 
> > This is only implemented for string-based mount options since doing
> > this with binary options isn't really feasible.
> 
> It might be feasible if mount.nfs were smart enough to read /etc/mtab 
> and merge the old mount options with the remount options.

Yeah, but in that case you'd need a new kernel + a new nfs-utils. If
you're going to do that then you might as well just use the (far
superior) string based options anyway.

IMO, it's not worth the effort to implement this for binary options...

-- 
Jeff Layton <jlayton@redhat.com>
