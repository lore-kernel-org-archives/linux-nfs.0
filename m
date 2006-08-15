From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous
	performance-related	fixes
Date: Tue, 15 Aug 2006 11:23:03 +1000
Message-ID: <1155604983.16378.1843.camel@hole.melbourne.sgi.com>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
	<20060808154923.GA28855@fieldses.org>
	<1155091055.16378.14.camel@hole.melbourne.sgi.com>
	<20060814214313.GE20034@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCneD-0004f1-Vo
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 18:23:14 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCneD-0002Pj-AH
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 18:23:14 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060814214313.GE20034@fieldses.org>
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

On Tue, 2006-08-15 at 07:43, J. Bruce Fields wrote:
> On Wed, Aug 09, 2006 at 12:37:36PM +1000, Greg Banks wrote:
> > On Wed, 2006-08-09 at 01:49, J. Bruce Fields wrote:
> > > It'd be nice if we could avoid ripping out a working user interface that
> > > someone might be using....
> > 
> > I agree, but I don't believe a) it's working or b) anyone could
> > be getting any use out of it.
> 
> OK.  So the advice at
> 
> http://nfs.sourceforge.net/nfs-howto/ar01s05.html#nfsd_daemon_instances
> 
> is wrong?

Let's see.

> Most startup scripts, Linux and otherwise, start 8 instances of nfsd.
> In the early days of NFS, Sun decided on this number as a rule of
> thumb, and everyone else copied. There are no good measures of how
> many instances are optimal, but a more heavily-trafficked server may
> require more.

Correct.

> You should use at the very least one daemon per processor, but four to
> eight per processor may be a better rule of thumb. 

Wrong.  This rule might work up to 4 or 8 cpus, but only by
coincidence.  Try running knfsd on a 512 cpu machine; you don't
need anything like 512 to 4096 nfsd threads.  A better rule of
thumb would be 1 to 4 nfsds per simultaneously active client.
Of course that number is a lot harder to measure with the server
as it stands today.

> If you are using a 2.4 or higher kernel and you want to see how
> heavily each nfsd thread is being used, you can look at the file
> /proc/net/rpc/nfsd. The last ten numbers on the th line in that file
> indicate the number of seconds that the thread usage was at that
> percentage of the maximum allowable. If you have a large number in the
> top three deciles, you may wish to increase the number of nfsd
> instances.

This is true, except that

1.  the numbers are undercounted (the mechanism tends to err
    towards incrementing a lower bucket), and

2.  the numbers are never reset and are scaled to the number of
    nfsd daemons, so to tell whether your change in the number
    of nfsds was helpful you need to reload the nfsd module or
    reboot.

> This is done upon starting nfsd using the number of instances as the
> command line option, 

Or by echoing a number into /proc/fs/nfsd/threads.

> and is specified in the NFS startup script (/etc/rc.d/init.d/nfs on
> Red Hat) as RPCNFSDCOUNT. See the nfsd(8) man page for more
> information.

On SUSE the file is /etc/sysconfig/nfs and the variable is
USE_KERNEL_NFSD_NUMBER.

> > An earlier version of the patch left the data structures in place
> > and just reported them as zeros in the /proc file.  Would that
> > be preferrable?
> 
> I'm not sure that makes any difference.

Fair enough.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
