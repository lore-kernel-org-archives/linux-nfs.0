From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: fix reference counting for NFSv4 callback thread
Date: Mon, 11 Feb 2008 10:50:21 -0500
Message-ID: <1202745024.10117.0.camel@heimdal.trondhjem.org>
References: <1202742020-28080-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1202742020-28080-1-git-send-email-jlayton@redhat.com>
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


On Mon, 2008-02-11 at 10:00 -0500, Jeff Layton wrote:
> The reference counting for the NFSv4 callback thread stays artificially
> high. When this thread comes down, it doesn't properly tear down the
> svc_serv, causing a memory leak. In my testing on an older kernel on
> x86_64, memory would leak out of the 8k kmalloc slab. So, we're leaking
> at least a page of memory every time the thread comes down.
> 
> svc_create() creates the svc_serv with a sv_nrthreads count of 1, and
> then svc_create_thread() increments that count. Whenever the callback
> thread is started it has a sv_nrthreads count of 2. When coming down, it
> calls svc_exit_thread() which decrements that count and if it hits 0, it
> tears everything down. That never happens here since the count is always
> at 2 when the thread exits.
> 
> The problem is that nfs_callback_up() should be calling svc_destroy() on
> the svc_serv on both success and failure. This is how lockd_up_proto()
> handles the reference counting, and doing that here fixes the leak.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---

Thanks Jeff! Applied.

Cheers
  Trond
