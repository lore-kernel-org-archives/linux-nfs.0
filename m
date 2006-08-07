From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: PATCH 2 of 4] cpumask: export cpu_online_map
	and	cpu_possible_map consistently
Date: Mon, 07 Aug 2006 13:05:40 +1000
Message-ID: <1154919940.29877.73.camel@hole.melbourne.sgi.com>
References: <1154669759.21040.2353.camel@hole.melbourne.sgi.com>
	<Pine.LNX.4.64.0608040730430.16814@montezuma.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9vRQ-0002NY-Lc
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 20:06:08 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G9vRQ-0004Lx-WB
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 20:06:09 -0700
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
In-Reply-To: <Pine.LNX.4.64.0608040730430.16814@montezuma.fsmlabs.com>
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

On Sat, 2006-08-05 at 00:32, Zwane Mwaikambo wrote:
> On Fri, 4 Aug 2006, Greg Banks wrote:
> 
> > cpumask: ensure that the cpu_online_map and cpu_possible_map bitmasks,
> > and hence all the macros in <linux/cpumask.h> that require them, are
> > available to modules for all supported combinations of architecture
> > and CONFIG_SMP.
> > 
> > Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> > ---
> > 
> >  arch/arm/kernel/smp.c           |    2 ++
> >  arch/cris/arch-v32/kernel/smp.c |    1 +
> >  arch/sh/kernel/smp.c            |    1 +
> >  kernel/sched.c                  |    3 +++
> >  4 files changed, 7 insertions(+)
> > 
> > Index: linux-2.6.18-rc2/kernel/sched.c
> > ===================================================================
> > --- linux-2.6.18-rc2.orig/kernel/sched.c	2006-08-01 17:53:25.000000000 +1000
> > +++ linux-2.6.18-rc2/kernel/sched.c	2006-08-02 23:01:20.535457863 +1000
> > @@ -4348,7 +4348,10 @@ EXPORT_SYMBOL(cpu_present_map);
> >  
> >  #ifndef CONFIG_SMP
> >  cpumask_t cpu_online_map __read_mostly = CPU_MASK_ALL;
> > +EXPORT_SYMBOL_GPL(cpu_online_map);
> 
> >  cpumask_t cpu_possible_map;
> > +EXPORT_SYMBOL(cpu_possible_map);
> >  cpumask_t cpu_online_map;
> > +EXPORT_SYMBOL(cpu_online_map);
> 
> How come these are of different export types?

Because I screwed up.  Fix coming later.  I presume _GPL
is the favoured form?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
