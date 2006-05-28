From: Neil Brown <neilb@suse.de>
Subject: Re: NFS and fuser
Date: Mon, 29 May 2006 09:43:38 +1000
Message-ID: <17530.13738.96859.130482@cse.unsw.edu.au>
References: <20060528231319.GA31396@enc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkUvG-0000kX-Su
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:43:50 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FkUvG-0003IX-PM
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:43:50 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FkUvF-0005lw-Af
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:43:50 -0700
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
> Hello,
>   I am the current maintainer of the psmisc package, which includes a
> program called fuser.  fuser lets someone work out which process has
> opened a "file", using a wide meaning for the word file. I currently
> have a NFS-related bug which I'm hoping the list can help me with.
> 
> The problem is if knfsd exports a directory out, it does not show
> up in its /proc/<pid>/fd/ directory.  I am looking for a nice clean way
> of determining what directories knfsd has exported. It appears for
> example that /proc/fs/nfs/exports does not appear in all versions of
> Linux.

/proc/fs/nfs/exports should appear in all versions of Linux that
server nfs.  That would be the best thing to use.

Why leads you to believe that it does not appear in all versions of
Linux?

NeilBrown


> 
> Another way would be to read /var/lib/nfs/xtab, but I do not know if
> this file location is always going to be there.
> My main concern is whatever assumptions I make (eg file X is always
> located at Y) are reasonable ones.
> 
> I'm not on the NFS list so if you could CC me directly that would be
> great.
> 
>  - Craig
> -- 
> Craig Small      GnuPG:1C1B D893 1418 2AF4 45EE  95CB C76C E5AC 12CA DFA5
> Eye-Net Consulting http://www.enc.com.au/   MIEE         Debian developer
> csmall at : enc.com.au                      ieee.org           debian.org
> 
> 
> -------------------------------------------------------
> All the advantages of Linux Managed Hosting--Without the Cost and Risk!
> Fully trained technicians. The highest number of Red Hat certifications in
> the hosting industry. Fanatical Support. Click to learn more
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
