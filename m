From: Craig Small <csmall@enc.com.au>
Subject: Re: NFS and fuser
Date: Mon, 29 May 2006 09:54:59 +1000
Message-ID: <20060528235459.GB31396@enc.com.au>
References: <20060528231319.GA31396@enc.com.au> <17530.13738.96859.130482@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkV69-0001rN-5H
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:55:05 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FkV69-0004Ch-0L
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:55:05 -0700
Received: from ppp114-209.static.internode.on.net ([150.101.114.209] helo=mail.enc.com.au)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FkV68-0007yq-K8
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:55:05 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17530.13738.96859.130482@cse.unsw.edu.au>
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

On Mon, May 29, 2006 at 09:43:38AM +1000, Neil Brown wrote:
> On Monday May 29, csmall@enc.com.au wrote:
> > Hello,
> >   I am the current maintainer of the psmisc package, which includes a
> > program called fuser.  fuser lets someone work out which process has
> > opened a "file", using a wide meaning for the word file. I currently
> > have a NFS-related bug which I'm hoping the list can help me with.
> > 
> > The problem is if knfsd exports a directory out, it does not show
> > up in its /proc/<pid>/fd/ directory.  I am looking for a nice clean way
> > of determining what directories knfsd has exported. It appears for
> > example that /proc/fs/nfs/exports does not appear in all versions of
> > Linux.
> 
> /proc/fs/nfs/exports should appear in all versions of Linux that
> server nfs.  That would be the best thing to use.
> 
> Why leads you to believe that it does not appear in all versions of
> Linux?
At least some people don't have that file.
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=356655

On the one nfs server I can see (Debian 2.6.8) it has that file.
It may be the way to go, if the file is not there all that happens is
that you go back to current behaviour, which is fuser doesn't "see"
the exports.

 - Craig

-- 
Craig Small      GnuPG:1C1B D893 1418 2AF4 45EE  95CB C76C E5AC 12CA DFA5
Eye-Net Consulting http://www.enc.com.au/   MIEE         Debian developer
csmall at : enc.com.au                      ieee.org           debian.org


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
