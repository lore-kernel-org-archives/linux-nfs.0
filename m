From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] NFS: implement option checking when remounting NFS
	filesystems (try #2)
Date: Sun, 20 Apr 2008 15:03:17 -0400
Message-ID: <20080420150317.27b49725@tleilax.poochiereds.net>
References: <1208010798-22782-1-git-send-email-jlayton@redhat.com>
	<1208710571.9518.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1208710571.9518.8.camel@heimdal.trondhjem.org>
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

On Sun, 20 Apr 2008 12:56:11 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> It might be nice also to signal when someone tries to convert a udp
> mount into a tcp mount, or change the server address...
> You don't need to do that in the same patch, but it is a common mistake
> that even experienced admins make.
> 

The original patch should make the mount call return -EINVAL if someone
tries to change from tcp to udp, or vice versa since that would change
the flags.

The original patch didn't catch changes to "addr=", but the one I just
sent out should do so.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
