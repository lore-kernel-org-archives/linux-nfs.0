From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage
Date: Mon,  8 Jun 2009 15:12:05 +0900 (JST)
Message-ID: <20090608150417.437C.A69D9226@jp.fujitsu.com>
References: <20090608055326.GA10843@localhost> <20090608055659.GA11538@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:39001 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbZFHGMG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 02:12:06 -0400
In-Reply-To: <20090608055659.GA11538@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> btw, can anyone explain these NFS warnings? It happens in a very
> memory tight and busy nfsroot system.
> 
> [  113.267340] NFS: Server wrote zero bytes, expected 3671.
> [  423.202607] NFS: Server wrote zero bytes, expected 108.
> [  723.588411] NFS: Server wrote zero bytes, expected 560.
> [ 1060.246747] NFS: Server wrote zero bytes, expected 54.
> [ 1397.841183] NFS: Server wrote zero bytes, expected 402.
> [ 1779.545035] NFS: Server wrote zero bytes, expected 319.

server side write function is below

-----------------------------------------------------------
static __be32
nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
                                loff_t offset, struct kvec *vec, int vlen,
                                unsigned long *cnt, int *stablep)
{
(snip)
        host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);	//(1)

(snip)
                /*
                 * Gathered writes: If another process is currently
                 * writing to the file, there's a high chance
                 * this is another nfsd (triggered by a bulk write
                 * from a client's biod). Rather than syncing the
                 * file with each write request, we sleep for 10 msec.
                 *
                 * I don't know if this roughly approximates
                 * C. Juszak's idea of gathered writes, but it's a
                 * nice and simple solution (IMHO), and it seems to
                 * work:-)
                 */
                if (EX_WGATHER(exp)) {
(snip)
                        if (inode->i_state & I_DIRTY) {
                                dprintk("nfsd: write sync %d\n", task_pid_nr(current));
                                host_err=nfsd_sync(file);		// (2)
                        }
                }
(snip)
        dprintk("nfsd: write complete host_err=%d\n", host_err);
        if (host_err >= 0) {
                err = 0;
                *cnt = host_err;
        } else
                err = nfserrno(host_err);
out:
        return err;
}
---------------------------------------------------------------------------

if (1) or (2) makes host_err == 0, it makes your warning messages.

Thanks.



