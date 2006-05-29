From: Neil Brown <neilb@suse.de>
Subject: Re: NFS and fuser
Date: Mon, 29 May 2006 10:16:03 +1000
Message-ID: <17530.15683.868564.165086@cse.unsw.edu.au>
References: <20060528231319.GA31396@enc.com.au>
	<17530.13738.96859.130482@cse.unsw.edu.au>
	<20060528235459.GB31396@enc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkVQb-0004Cj-N0
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 17:16:13 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FkVQb-00069C-E8
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 17:16:13 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FkVQb-0004Jp-5w
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 17:16:13 -0700
To: Craig Small <csmall@enc.com.au>
In-Reply-To: message from Craig Small on Monday May 29
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

On Monday May 29, csmall@enc.com.au wrote:
> > 
> > Why leads you to believe that it does not appear in all versions of
> > Linux?
> At least some people don't have that file.
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=356655
> 
> On the one nfs server I can see (Debian 2.6.8) it has that file.
> It may be the way to go, if the file is not there all that happens is
> that you go back to current behaviour, which is fuser doesn't "see"
> the exports.

Any Linux system that is exporting files using the in-kernel NFS
server and that has /proc mounted will DEFINITELY have 
  /proc/fs/nfs/exports
If John is not seeing this on his 2.6.11 system then I can only assume
that the 'nfsd' module isn't loaded.  Maybe he is using the userspace
nfs server, or not using NFS at all.


Using the equivalent of "showmount -e" would not be correct as that
just report what directories the nfs server is willing to export.
On 2.6 kernels the recommend configuration results in the kernel not
knowing about exported filesystems unless they are actually being
currently used (though with a fairly generous timeout).
Presumably 'fuser' should only report files/directories that are
actually 'open' inside the kernel.  Thus 'showmount -e' is 
not appropriate.

I stand by my asserting that examining /proc/fs/nfs/exports is the
best thing to do.

NeilBrown


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
