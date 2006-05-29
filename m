From: Theo Markettos <nfs@markettos.org.uk>
Subject: Multiple heterogeneous NFS servers on one machine
Date: Mon, 29 May 2006 19:24:00 +0100
Message-ID: <20060529182400.GQ13353@chiark.greenend.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkmPU-0003bc-QU
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 11:24:12 -0700
Received: from chiark.greenend.org.uk ([193.201.200.170])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FkmPL-0008VC-Dw
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 11:24:03 -0700
Received: by chiark.greenend.org.uk (Debian Exim 3.36 #1) with local
	(return-path theom@chiark.greenend.org.uk)
	id 1FkmPI-0006EG-00
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 19:24:00 +0100
To: nfs@lists.sourceforge.net
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

I need to run two different NFS servers on the same 2.6 Linux machine.  This
is because I need the --re-export option from Debian's 'nfs-user-server'
package, and I also need an NFS 3 server, for which I'm using Linux's kernel
mode server.  I've been trying to work out a way of doing this.

My NFS clients can be told which ports mountd and nfsd are listening on, so
it should be straightforward.  However I can't seem to get portmap out of
the equation.  When I run just the kernel server, it works.  It also works
if I tell my client explicitly which ports the kernel server mountd/nfsd are
listening on.  However if I run just mountd and nfsd from the user mode
server, without portmap, my client is giving RPC failures.  More confusingly
if I run them when the kernel server is also running, neither work.  Killing
user mode nfsd makes the kernel server work again.

So I think something is breaking portmap.  I've hacked the source of the
user mode server mountd/nfsd to not call svc_register() (see man 3 rpc) in
an attempt to not confuse portmap with two NFS servers running at once. 
This at least means the kernel server works, but the user mode server
doesn't.

I'm still getting RPC errors when I run user mode mountd/nfsd without the
kernel server after this modification, and running portmap doesn't help.

Is it possible to run NFS without portmap?  Or are there any other
suggestions for running two NFS servers on the same machine?  I thought
about giving the machine two IP addresses, but neither server has an option
to listen on a specific interface.  Or is there some way that the kernel NFS
server can export already mounted remote directories (ie machine B exports
directory containing filesystem mounted from machine A, where machine A's
directory may be mounted with some random non-NFS network filesystem), which
was the need for --re-export in the first place?

Thanks
Theo

-- 
Theo Markettos                 theo@markettos.org.uk
Clare Hall, Cambridge          atm26@cam.ac.uk
CB3 9AL, UK                    http://www.markettos.org.uk/


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
