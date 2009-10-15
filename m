From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS4ERR_FILE_OPEN handling in Linux
Date: Thu, 15 Oct 2009 08:53:24 -0400
Message-ID: <1255611204.4317.19.camel@heimdal.trondhjem.org>
References: <19158.28240.964203.341327@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <19158.28240.964203.341327@notabene.brown>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-10-15 at 11:35 +1100, Neil Brown wrote:
> Hi Trond,
> 
>  Following up for a customer who had problem with NFSv4 when talking
>  to a Solaris server with "nbman" enabled, I have questions about the
>  handling of NFS4ERR_FILE_OPEN.
>  In particular:
>    1/ should commit c514983d8d2260020543a81589a2b8c7d4bdab4e be
>       reverted, and
>    2/ should nfs_errtbl map NFS4ERR_FILE_OPEN to -EBUSY rather than
>       defaulting to -EIO
> 
>  That commit, included below for reference, causes the NFS client to
>  retry indefinitely if NFS4ERR_FILE_OPEN is returned.  This
>  contradicts the comment which suggests it will only "retry a few
>  times" and cannot be correct as a file could be held open (thus
>  causing the error) indefinitely.

I'm unfortunately unfamiliar with 'nbman' on Solaris. Could you please
explain what it is, and why it should cause the nfs server to start
returning NFS4ERR_FILE_OPEN?

As far as I know, the purpose of the NFS4ERR_FILE_OPEN error was to
address the issue of MS Windows semantics, which do not allow certain
operations (mainly unlink() and rename()) on an open file. Since the
error is supposed to be transient (i.e. is caused by a lock) the current
behaviour was chosen in order to try to provide posix-like semantics in
these situations.
While we could change the behaviour to return -EBUSY, that might
conceivably break applications that expect to be able to create and
destroy temporary files. I therefore think that some attempt should be
made to wait and retry before we start returning application errors.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
