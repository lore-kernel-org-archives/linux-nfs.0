From: Neil Brown <neilb@suse.de>
Subject: Re: BUG: soft lockup detected on CPU#0! (linux-2.6.14)
Date: Mon, 7 Nov 2005 08:56:53 +1100
Message-ID: <17262.31781.497775.640424@cse.unsw.edu.au>
References: <20051106193142.GD26862@skl-net.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EYsVb-0002Vm-5c
	for nfs@lists.sourceforge.net; Sun, 06 Nov 2005 13:57:03 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EYsVb-0001Wq-1d
	for nfs@lists.sourceforge.net; Sun, 06 Nov 2005 13:57:03 -0800
To: Andre Noll <maan@systemlinux.org>
In-Reply-To: message from Andre Noll on Sunday November 6
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sunday November 6, maan@systemlinux.org wrote:
> Hi
> 
> I regularly get these on the current 2.6.14 kernel under heavy load.
> Backtrace differs, but nfsd is always involved:
> 
> Nov  4 12:46:44 p133 kernel: BUG: soft lockup detected on CPU#0!

This seems to suggest that the nfsd thread is always runnable, which
implies a read-only load with everything in cache - at least for the
10 seconds leading up to each of these errors.  Is that likely?

The following patch might fix it.  Please let me know the result.

Thanks,
NeilBrown


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |    1 +
 1 file changed, 1 insertion(+)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2005-11-07 08:53:40.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2005-11-07 08:53:48.000000000 +1100
@@ -1181,6 +1181,7 @@ svc_recv(struct svc_serv *serv, struct s
 	arg->tail[0].iov_len = 0;
 
 	try_to_freeze();
+	cond_resched();
 	if (signalled())
 		return -EINTR;
 


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
