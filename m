From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: implement option checking when remounting NFS
	filesystems
Date: Fri, 11 Apr 2008 15:19:15 -0400
Message-ID: <47FFB9B3.1020703@redhat.com>
References: <1207937413-16189-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207937413-16189-1-git-send-email-jlayton@redhat.com>
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

Jeff Layton wrote:
> When remounting an NFS or NFS4 filesystem, the new NFS options are not
> respected, yet the remount will still return success. This patch adds
> a remount_fs sb op for NFS that checks any new nfs mount options against
> the existing ones and fails the mount if any have changed.
>
> This is only implemented for string-based mount options since doing
> this with binary options isn't really feasible.

What about respecting the new options as makes sense and rejecting
those which absolutely can't be changed dynamically?

       ps
