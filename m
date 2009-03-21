From: Paul Collins <paul-dsjeNyW6Qm/D+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>
Subject: Re: [NFS] problem with rpc.statd
Date: Sat, 21 Mar 2009 14:20:25 +1300
Message-ID: <874oxnllie.fsf@burly.wgtn.ondioline.org>
References: <49C43847.9080206@shadlen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Maria McKinley <maria-3uEUQlRWSvdAfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51967 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487AbZCUBlR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2009 21:41:17 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LkqD3-0000LK-Ew
	for linux-nfs@vger.kernel.org; Sat, 21 Mar 2009 12:41:13 +1100
In-Reply-To: <49C43847.9080206-3uEUQlRWSvdAfugRpC6u6w@public.gmane.org> (Maria McKinley's message of "Fri,
	20 Mar 2009 17:43:51 -0700")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maria McKinley <maria-3uEUQlRWSvdAfugRpC6u6w@public.gmane.org> writes:

> Things work well up until it is time to mount the file system from
> fstab (ie, it mounts everything ro, makes it all the way through init 
> and gives me a command prompt). The rw mount is not happening because 
> rpc.statd never starts. If I try to start rpc.statd by hand, it 
> complains that: Opening /var/run/rpc.statd.pid failed: Read-only file 
> system. Since I am mounting the root directory over nfs, it makes sense 
> for this file to be read-only until rpc.statd starts and  Is there any 
> way I can start statd without a pid file until I get the root file 
> system mounted rw? Or something else to try?

Try setting RAMRUN=yes in /etc/default/rcS, which will mount a tmpfs on
/var/run early in the boot process.  I think I read something about
defaulting this to yes being a release goal for squeeze, so there may be
lenny packages that won't like this.

-- 
Paul Collins
Wellington, New Zealand

Dag vijandelijk luchtschip de huismeester is dood

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

