From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] kNFSd - 3 of 5 - Allow sunrpc/svc cache init function
 to modify the "key"
Date: Sat, 7 Feb 2004 01:30:53 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040207013053.781f2dd1.akpm@osdl.org>
References: <20040206161050.27799.patches@notabene>
	<E1AoyIo-0007Fb-00@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ApOlb-0005Yq-Eg
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 01:28:47 -0800
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1ApOla-0007rm-Ut
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 01:28:47 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <E1AoyIo-0007Fb-00@notabene>
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

NeilBrown <neilb@cse.unsw.edu.au> wrote:
>
>  When adding a item to a sunrpc/svc cache that contains kmalloced
>  data it is usefully to move the malloced data out of the key object
>  into the new cache object rather than copying (as then we would need to
>  cope with kmalloc failure and such).  This means modifying the original.
> 
>  If the kmalloced data forms part of the key, then we must not move the data out until 
>  after the key isn't needed any more.  So this patch moves the call to "INIT" on a
>  new item (which fills in the key) to *after* the item has been found (or not), and
>  also makes sure we only call the HASH function once.
>  Thanks to  "J. Bruce Fields" <bfields@fieldses.org>
> 
>  also
> 
>   1/ remove unnecessary assignment
>   2/ fix comments that lag behind implementation.

Whether or not patch #2 is applied, this one causes a deadlock when
exportfs is running.

(gdb) bt
#0  gdb_interrupt (irq=-1068954208, dev_id=0x0, regs=0xce98de98) at arch/i386/lib/kgdb_serial.c:198
#1  0xc010de23 in handle_IRQ_event (irq=4, regs=0xce98de98, action=0x3) at arch/i386/kernel/irq.c:229
#2  0xc010e1e7 in do_IRQ (regs=
      {ebx = -1068657432, ecx = 315736640, edx = 0, esi = -1047921116, edi = 1835953411, ebp = -828842280, eax = -1068657432, xds = 123, xes = 123, orig_eax = -252, eip = -1072651591, xcs = 96, eflags = 647, esp = -1072540272, xss = 0}) at arch/i386/kernel/irq.c:493
#3  0xc010c368 in common_interrupt () at /tmp/ccc0QsD2.s:2044
#4  0xc03e8c7a in auth_domain_lookup (item=0xc189fe40, set=2) at net/sunrpc/svcauth.c:145
#5  0xc03e8d92 in unix_domain_find (name=0xcf210004 "mnm") at net/sunrpc/svcauth_unix.c:62
#6  0xc020da04 in exp_addclient (ncp=0xcf210004) at fs/nfsd/export.c:1093
#7  0xc0205c94 in TA_write (file=0xce3a7880, buf=0xbfffd534 "mnm", size=1136, pos=0xce3a78a0)
    at fs/nfsd/nfsctl.c:122
#8  0xc018f40c in sys_nfsservctl (cmd=-835028864, arg=0x3f8, res=0x0) at fs/nfsctl.c:109

gdb doesn't show it, but we're actually stuck in __write_lock_failed(). 
I'd be suspecting that the rwlock in DefineCacheLookup() is not
initialised.




-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
