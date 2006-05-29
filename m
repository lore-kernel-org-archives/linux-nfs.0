From: Neil Brown <neilb@suse.de>
Subject: Re: 2.4 vs 2.6
Date: Mon, 29 May 2006 15:55:19 +1000
Message-ID: <17530.36039.227704.325645@cse.unsw.edu.au>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
	<20060526081905.73641.qmail@web51609.mail.yahoo.com>
	<20060526193118.GB17761@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	nfs@lists.sourceforge.net, Vijay Chauhan <kernel.vijay@gmail.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fkaiy-0006KV-Ao
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 22:55:32 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fkaiy-0007Zf-5x
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 22:55:32 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Fkaix-0002GB-Jr
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 22:55:32 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Friday May 26
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

On Friday May 26, bfields@fieldses.org wrote:
> On Fri, May 26, 2006 at 01:19:05AM -0700, mehta kiran wrote:
> > Hi,
> > 
> > 1. I noticed that 2.6 kernel is not aware of 
> >    exportfs until client tries to mount. It only
> >    after this that proc nfsd filesystem shows this
> >    in list of exports due to upcall.
> >    Was 2.4 kernel aware of exportfs when the
> >    filesystem was first exported or mounted ?
> > 
> > 2. Can you let me know advantage 2.6 export approach
> >    over 2.4 export approach ? 
> >    Is this approach required due to 
> >    security/authentication integration with NFS(say 
> >    ip->name conversion for security ) ?
> 
> The kernel has to know whether an incoming IP address matches, say,
> "*.umich.edu."  But we don't want to add an entire DNS client
> implementation to the kernel.  And we also can't preload the kernel with
> every possible IP address that might match *.umich.edu.  So we allow
> the kernel to ask mountd for that information when it needs it.
> 
> This isn't actually necessary for an NFSv2/v3 server, because mountd
> always gets a "mount" request from any client before the kernel gets any
> NFS requests from that client, so mountd can tell the kernel about the
> new client then.

Not exactly necessary, but without it we depend on 'rmtab' to record
which clients have the filesystem mounted across a server reboot, and
it is not possible to maintain an rmtab file reliably.

> 
> But NFSv4 clients don't contact mountd first.  Neither do v2/v3 clients
> that are failing over from another server.  So you need the upcalls to
> handle those cases.
> 
> That justifies the auth_unix_ip upcall, anyway; I'm less sure about the
> others.

The nfsd.fh upcall - which maps a file-handle-fragment to a directory -
can be used to implementing on-demand loading of filesystems,
e.g. CDroms from a CD library.  We don't actually do that now, but we
could.
It also means that if a filesystem isn't currently being used by a
client, (where 'currently' means in the last 30 minutes I think), then
you can unmount it without having to unexport it.  This is (arguably?)
a good thing.

nfsd.export is needed because once auth.unix.ip and nfsd.fh have
provided their information - it combines the two together to get
export options.

auth.domain was a mistake that is gone in recent kernels.

That leaves nfs4.nametoid and nfs4.idtoname.  I'm sure they do
something useful.... :-)

Hope that completes the clarification.

NeilBrown


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
