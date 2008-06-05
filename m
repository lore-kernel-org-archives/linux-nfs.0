From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Wed, 4 Jun 2008 20:35:04 -0400
Message-ID: <20080604203504.62730951@tleilax.poochiereds.net>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
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

On Thu, 5 Jun 2008 00:33:54 +0100
"Daniel J Blueman" <daniel.blueman@gmail.com> wrote:

> Having experienced 'mount.nfs4: internal error' when mounting nfsv4 in
> the past, I have a minimal test-case I sometimes run:
> 
> $ while :; do mount -t nfs4 filer:/store /store; umount /store; done
> 
> After ~100 iterations, I saw the 'mount.nfs4: internal error',
> followed by symptoms of memory corruption [1], a locking issue with
> the reporting [2] and another (related?) memory-corruption issue
> (off-by-1?) [3]. A little analysis shows memory being overwritten by
> (likely) a poison value, which gets complicated if it's not
> use-after-free...
> 
> Anyone dare confirm this issue? NFSv4 server is x86-64 Ubuntu 8.04
> 2.6.24-18, client U8.04 2.6.26-rc4; batteries included [4].
> 
> I'm happy to decode addresses, test patches etc.
> 
> Daniel
> 

Looks like it fell down while trying to take down the kthread during a
failed mount attempt. I have to wonder if I might have introduced a
race when I changed nfs4 callback thread to kthread API. I think we may
need the BKL around the last 2 statements in the main callback thread
function. If you can easily reproduce this, could you test the
following patch and let me know if it helps?

Note that this patch is entirely untested, so test it someplace
non-critical ;-).

Signed-off-by: Jeff Layton <jlayton@redhat.com>


diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index c1e7c83..a3e83f9 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -90,9 +90,9 @@ nfs_callback_svc(void *vrqstp)
 		preverr = err;
 		svc_process(rqstp);
 	}
-	unlock_kernel();
 	nfs_callback_info.task = NULL;
 	svc_exit_thread(rqstp);
+	unlock_kernel();
 	return 0;
 }
