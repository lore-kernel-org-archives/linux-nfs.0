From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 004 of 4] knfsd: Provide sunrpc pool_mode module
	option
Date: Tue, 6 Mar 2007 16:11:50 +1100
Message-ID: <17900.63510.307044.43948@notabene.brown>
References: <20070306131103.26638.patches@notabene>
	<1070306021520.26937@suse.de>
	<20070305205757.2d5db738.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HORz7-0006BZ-Ss
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 21:13:14 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HORz7-00084R-4W
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 21:13:16 -0800
In-Reply-To: message from Andrew Morton on Monday March 5
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Monday March 5, akpm@linux-foundation.org wrote:
> On Tue, 6 Mar 2007 13:15:20 +1100 NeilBrown <neilb@suse.de> wrote:
> 
> > Provide a module param "pool_mode" for sunrpc.ko which allows a
> > sysadmin to choose the mode for mapping NFS thread service pools
> > to CPUs.  Values are:
> > 
> > auto	    choose a mapping mode heuristically
> > global	    (default, same as the pre-2.6.19 code) a single global pool
> > percpu	    one pool per CPU
> > pernode	    one pool per NUMA node
> > 
> > Note that since 2.6.19 the hardcoded behaviour has been "auto",
> > this patch makes the default "global".
> > 
> > The pool mode can be changed after boot/modprobe using /sys, if the
> > NFS and lockd services have been shut down.  A useful side effect of
> > this change is to fix a small memory leak when unloading the module.
> 
> Mutter.  Is this really suitable and needed for 2.6.21 at this stage in
> its life?

Something is definitely needed.  Currently on a 4-way SMP machine,
nfsd might only use 1 CPU (depends a bit on irq routing I think).

If that patch is too big, maybe this one?

NeilBrown

--------------------------------
Avoid using nfsd process pools on SMP machines.

From: Neil Brown <neilb@suse.de>

process-pools have real benefits for NUMA, but on SMP
machines they only work if network interface interrupts
go to all CPUs (via round-robin or multiple nics).  This is
not always the case, so disable the pools in this case until
a better solution is developped.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svc.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2007-03-06 16:07:19.000000000 +1100
+++ ./net/sunrpc/svc.c	2007-03-06 16:08:53.000000000 +1100
@@ -79,7 +79,11 @@ svc_pool_map_choose_mode(void)
 		 * x86_64 kernel on Xeons.  In this case we
 		 * want to divide the pools on cpu boundaries.
 		 */
-		return SVC_POOL_PERCPU;
+		/* actually, unless your IRQs round-robin nicely,
+		 * this turns out to be really bad, so just
+		 * go GLOBAL for now until a better fix can be developped
+		 */
+		return SVC_POOL_GLOBAL;
 	}
 
 	/* default: one global pool */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
