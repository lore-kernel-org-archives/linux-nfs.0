From: Mario Storti <mstorti@intec.unl.edu.ar>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: Thu, 1 Jun 2006 14:54:10 +0000 (UTC)
Message-ID: <loom.20060601T164005-982@post.gmane.org>
References: <loom.20060531T205740-641@post.gmane.org> <loom.20060601T155144-450@post.gmane.org> <447EF8CA.3020200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FloZW-00062k-3o
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 07:54:50 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FloZV-0006Cm-Uw
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 07:54:50 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FloZS-0003mv-HM
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 07:54:50 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1FloZF-00012T-Bt
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 16:54:33 +0200
Received: from rev2009237.secyt.gov.ar ([rev2009237.secyt.gov.ar])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 16:54:33 +0200
Received: from mstorti by rev2009237.secyt.gov.ar with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 16:54:33 +0200
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

> What is the local file system type being exported on the NFS servers?

It is software RAID mounted on top of XFS. At first time we suspected
of this combination, and the first thing we do is to clone the system
on a plain ext3 filesystem without RAID. The cloned cluster with two
nodes exhibited exactly the same behaviour, so we don't think now that
the problem is in the combination of NFS with RAID+XFS. It ssems to be
something in the NFS setup/configuration itself. 

Thanks, Mario

-------------------------
Mario Alberto Storti     [cel. +54-342-156144983]
CIMEC (INTEC/CONICET-UNL), Guemes 3450 - 3000 Santa Fe, Argentina
Tel: +54-342-4511594 (ext 1015), Tel/Fax: +54-342-4511169
e-mail: mstorti at intec dot unl dot edu dot ar
http://www.cimec.org.ar/mstorti
-------------------------




-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
