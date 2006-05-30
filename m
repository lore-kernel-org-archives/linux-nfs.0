From: Greg Banks <gnb@sgi.com>
Subject: Re: 2.4 vs 2.6
Date: Tue, 30 May 2006 11:12:08 +1000
Message-ID: <20060530011208.GB12818@sgi.com>
References: <17526.44653.228663.713864@cse.unsw.edu.au> <20060526081905.73641.qmail@web51609.mail.yahoo.com> <20060526193118.GB17761@fieldses.org> <17530.36039.227704.325645@cse.unsw.edu.au> <20060529160236.GC6832@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	mehta kiran <kiranmehta1981@yahoo.com>, nfs@lists.sourceforge.net,
	Vijay Chauhan <kernel.vijay@gmail.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fksmj-0005Br-8a
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 18:12:37 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fksmi-0001Cr-Th
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 18:12:37 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060529160236.GC6832@fieldses.org>
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

On Mon, May 29, 2006 at 12:02:36PM -0400, J. Bruce Fields wrote:
> On Mon, May 29, 2006 at 03:55:19PM +1000, Neil Brown wrote:
> > Not exactly necessary, but without it we depend on 'rmtab' to record
> > which clients have the filesystem mounted across a server reboot, and
> > it is not possible to maintain an rmtab file reliably.
> 
> Oh, right.  Hm.  I don't actually understand exactly what the obstacles
> are to maintaining it reliably, though intuitively it's easy to believe
> that it's impossible.  Is the problem just clients that die and never
> come back, or are there inherent race coditions updating the rmtab on
> unmount?

Clients can also ignore network errors when they unmount, or do
some kind of forced unmount which doesn't send an RPC to mountd.
Because clients still work regardless of whether the serverside state
is cleaned up, umount is effectively optional.

So rmtab is not only unreliable but tends to accumulate cruft.  I've
seen reports of rmtab growing to over 500 megabytes (admittedly not
on a Linux box, but the principle is the same).

> > nfsd.export is needed because once auth.unix.ip and nfsd.fh have
> > provided their information - it combines the two together to get
> > export options.
> 
> I don't see why this *has* to be done on demand, though, unless the
> export table is extremely large and only sparsely used.  I might be
> missing something.

/mnt/data *.domain1.company.com(ro,sync) *.domain2.company.com(rw,sync)

Also, ISTR that the combination of the nohide export option and
a client wildcard didn't work properly in 2.4 and the kernel upcall
to mountd in 2.6 fixed that.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
