From: Matthias Andree <matthias.andree@gmx.de>
Subject: Re: stale NFS file handle (2.4.20) ext3 LVM
Date: Fri, 20 Jun 2003 13:14:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030620111408.GC8061@merlin.emma.line.org>
References: <m3isr2kanm.fsf@merlin.emma.line.org> <3EF1CC36.8F3EC825@moving-picture.com> <m38yrx3dhx.fsf@merlin.emma.line.org> <3EF2D54C.73B9EDAA@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.dt.e-technik.uni-dortmund.de
	([129.217.163.1] helo=krusty.dt.e-technik.uni-dortmund.de ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TJqP-0007YT-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 04:14:13 -0700
Received: from m2a2.dyndns.org (krusty.dt.e-technik.uni-dortmund.de [129.217.163.1])
	by mail.dt.e-technik.uni-dortmund.de (Postfix) with ESMTP id D97F0A381D
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 13:14:09 +0200 (CEST)
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3EF2D54C.73B9EDAA@moving-picture.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 20 Jun 2003, James Pearson wrote:
> There was a posting from Neil Brown recently about possible changes for
> 2.6 kernels, that mentions doing away with rmtab - see:
> 
> http://marc.theaimsgroup.com/?l=linux-nfs&m=105331510308653&w=2

nfsd was supposed to be stateless ;-)

> > I configured the machine to create a tar.gz file of /var/lib/nfs at
> > boot-up time so I can have a look should it go wrong again. Maybe /var
> > is still too precious for XFS ;-)
> 
> Something I've considered doing, but never got round to it ...

I'm using this in SuSE 8.2's /etc/init.d/boot.local:

tar --quiet -czf /var/lib/nfs-backup-`date -u +%FT%H%M%SZ`.tar.gz /var/lib/nfs

Takes a recent GNU tar and a recent "date" command that knows %F as
YYYY-MM-DD format and -u for UTC.


-- 
Matthias Andree


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
