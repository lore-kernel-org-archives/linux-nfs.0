From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mountd segfault on itanium2
Date: Mon, 3 May 2004 21:01:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040504010158.GD3636@fieldses.org>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501030730.GE23287@polop.usc.edu> <20040504001718.GZ23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKoJu-0004iq-Qf
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 18:02:02 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BKoJu-000313-DC
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 18:02:02 -0700
Received: from bfields by pumpkin.fieldses.org with local (Exim 4.32)
	id 1BKoJq-00011L-Re
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 21:01:58 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20040504001718.GZ23287@polop.usc.edu>
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

On Mon, May 03, 2004 at 05:17:18PM -0700, Garrick Staples wrote:
> I'm slowly starting to wrap my brain around how these RPC calls work.  I've
> found something that I can't make sense of.  In my_svc_run(), it packs fds 3,
> 4, 5, 6, and 7 into select().  3, 4, and 5 are 3 files in /proc/net/rpc.  fd 6
>  and 7 are udp and tcp sockets.  During my umount/mount tests, fd 6 is the
> only set bit after the select(), and is then passed to svc_getreqset().
> 
> But just before the segfault, select() sets fd 5, which is
> /proc/net/rpc/nfsd.fh/channel.  The thing that I don't understand is that fd 5
> is being passed to svc_getreqset().  Shouldn't svc_getreqset() be only for fds
> of sockets that have pending rpc calls?  Should fd 5 be cleared from the fdset
> before calling svc_getreqset()?

Cool, good detective work, I think that must be it.  Other people
weren't seeing it because you have to be using the new interface (have
nfsd mounted), and have to get an rpc call and a kernel upcall at the
same time.  Does clearing the bit end the segfaults?

--Bruce Fields

>From Garrick Staples <garrick@usc.edu>:

After mountd handles a cache upcall, we should clear the relevant bits in the
fd_set.


 utils/mountd/cache.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN utils/mountd/svc_run.c~cache_select_bugfix utils/mountd/svc_run.c
diff -puN utils/mountd/cache.c~cache_select_bugfix utils/mountd/cache.c
--- nfs-utils-1.0.6/utils/mountd/cache.c~cache_select_bugfix	2004-05-03 20:57:15.000000000 -0400
+++ nfs-utils-1.0.6-bfields/utils/mountd/cache.c	2004-05-03 20:57:15.000000000 -0400
@@ -315,6 +315,7 @@ int cache_process_req(fd_set *readfds) 
 		    FD_ISSET(fileno(cachelist[i].f), readfds)) {
 			cnt++;
 			cachelist[i].cache_handle(cachelist[i].f);
+			FD_CLR(fileno(cachelist[i].f), readfds);
 		}
 	}
 	return cnt;

_


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
