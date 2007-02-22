From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] provide sunrpc pool_mode module option
Date: Thu, 22 Feb 2007 13:20:46 +1100
Message-ID: <17884.65022.790059.307696@notabene.brown>
References: <20070221145818.GC23394@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HK3aY-0002rP-4t
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 18:21:42 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HK3aY-0001md-Su
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 18:21:44 -0800
In-Reply-To: message from Greg Banks on Thursday February 22
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

On Thursday February 22, gnb@sgi.com wrote:
> 
> Provide a module option "pool_mode" for sunrpc.ko which allows a
> sysadmin to choose the mode for mapping svc_pools to CPUs.  Values are:
> 
> auto	    choose a mapping mode heuristically
> global	    (default, same as the pre-2.6.19 code) a single global pool
> percpu	    one pool per CPU
> pernode	    one pool per NUMA node
> 
> Note that since 2.6.19 the hardcoded behaviour has been "auto",
> this patch makes the default "global".

-ENODOC .... Documentation/kernel-parameters.txt should have this
   documented as sunrpc.pool_mode

It bugs me slightly that you can only set this once.  If you want to
try a different option you have to reboot unless sunrpc is a module in
which case you can rmmod and insmod.

What would you think of making 'initialised' a count of active
services that gets decremented from svc_destroy?  Then you could just
stop all nfsd (and lockd) threads, write a new value to 
 /sys/module/sunrpc/parameters/pool_mode
and restart the threads.

I'm happy to hear arguments against this - it is just an idea.

Otherwise, patch looks ok,

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
