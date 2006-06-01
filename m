From: Mario Storti <mstorti@intec.unl.edu.ar>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: Thu, 1 Jun 2006 16:35:45 +0000 (UTC)
Message-ID: <loom.20060601T175939-701@post.gmane.org>
References: <loom.20060531T205740-641@post.gmane.org> <loom.20060601T155144-450@post.gmane.org> <447EF8CA.3020200@redhat.com> <loom.20060601T164005-982@post.gmane.org> <447F0E3D.9070809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Flq9v-0007hB-MZ
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 09:36:31 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Flq9v-0007JV-9A
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 09:36:31 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Flq9t-0006Uu-RF
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 09:36:31 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Flq9W-0001vz-Fs
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 18:36:07 +0200
Received: from rev2009237.secyt.gov.ar ([rev2009237.secyt.gov.ar])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 18:36:06 +0200
Received: from mstorti by rev2009237.secyt.gov.ar with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 18:36:06 +0200
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

Peter Staubach <staubach <at> redhat.com> writes:

> I see from the `nfsstat' output that this job mix is _very_ heavily write
> intensive.  I might suspect that this may be contributing to the issue
> being seen.  The consistency for files is very relaxed when those files
> are being written to.

The `nfsstat' results that I sent were cumulative. I learn now that in
theory we can zero them with `-z', but it seems not to work. Perhaps
there is some intense traffic when the slaves boot but not at the time
of making the `experiment'.  At that time the NFS traffic es
_extremely_ low. We change only a small text file (for reference it's
my ~/.bashrc) and check if the changes are reflected in the
nodes. There are no applications running at the nodes. 
 
> Are any special mount parameters being used?

No, we tried vers=2 for forcing version 2, also tried `noac'. Also
tried `async/sync' at the server side. None had effect on the
problem. `noac' of course reflected in a lack of efficiency, but the
problem persists. 

Thanks, Mario




-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
