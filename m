From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: PATCH 2 of 4] cpumask: export cpu_online_map
	and	cpu_possible_map consistently
Date: Mon, 07 Aug 2006 12:57:11 +1000
Message-ID: <1154919431.29877.69.camel@hole.melbourne.sgi.com>
References: <1154669759.21040.2353.camel@hole.melbourne.sgi.com>
	<44D35D99.601@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9vJ8-0001gO-FA
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 19:57:34 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G9vJ7-0005pc-S2
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 19:57:35 -0700
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <44D35D99.601@linux.intel.com>
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

On Sat, 2006-08-05 at 00:45, Arjan van de Ven wrote:
> Greg Banks wrote:
> > cpumask: ensure that the cpu_online_map and cpu_possible_map bitmasks,
> > and hence all the macros in <linux/cpumask.h> that require them, are
> > available to modules for all supported combinations of architecture
> > and CONFIG_SMP.
> 
> Are there any actual users of this?

knfsd-make-rpc-threads-pools-numa-aware.patch in -mm.

http://marc.theaimsgroup.com/?l=linux-kernel&m=115430697330586&w=2

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
