From: Olaf Kirch <okir@suse.de>
Subject: Re: async vs. sync
Date: Wed, 28 Jul 2004 10:56:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040728085644.GD20264@suse.de>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407261905.40248.bernd-schubert@web.de> <41055FE5.3030206@bruvoll.com> <200407270006.08581.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpkHf-00053x-PX
	for nfs@lists.sourceforge.net; Wed, 28 Jul 2004 01:59:35 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpkHf-0004nd-7z
	for nfs@lists.sourceforge.net; Wed, 28 Jul 2004 01:59:35 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200407270006.08581.bernd-schubert@web.de>
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

Hi,

the way the sync export option affects NFSv3 writes is limited to
COMMITs, so if you see a slow-down here it must be bottle-necking in
that part of the code.

Quite possibly, this is a problem of the underlying file system.
You're using a journaled file system, right? So what seems to happen
is that on every n-th commit call or so all nfsd processes stall
as the file system tries to write its journal. Note that the
VM currently allows dirty data to accumulate for up to 30 seconds
before it is forcibly written to disk (dirty_expire_centisecs sysctl).

A good way to simulate this is to run several iozone processes on the
server and tell them to sync() every 1 MB or so.

	iozone -s 1g -r 1m -o -i 0

This takes NFS out of the equation.

Maybe it would help to play with the dirty writeback strategy, e.g. by
lowering /proc/sys/vm/dirty_writeback_centisecs (to e.g. 250), increasing
dirty_background_ratio or lowering vm_dirty_ratio.

It may also be interesting to compare ext3 vs reiser here.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
