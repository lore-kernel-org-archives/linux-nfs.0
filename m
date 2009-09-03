Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16894 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454AbZICHqd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2009 03:46:33 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 3 Sep 2009 00:46:09 -0700
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <4A9F6027.9050807@s3group.cz>
From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
To: "Ondrej Valousek" <webserv@s3group.cz>,
        "Steve French" <smfrench@gmail.com>
Cc: <ffilzlnx@linux.vnet.ibm.com>, <linux-nfs@vger.kernel.org>,
        <nfsv4@linux-nfs.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        <jra@samba.org>, <agruen@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've always thought of NFS as a means for making physical file systems
available across a network.  NFS having its own ACLs doesn't fit this
model.  E.g., "NFS ACLs" will never be integrated into NTFS.  However, I
could imagine NFS ACLs solving the general problem if they were to form
a superset of the ACLs of exportable physical file systems, and the
mechanism for interpreting ACLs for a particular physical file system
could be encoded (or modularized) in such a way that NFS' evaluation of
ACL operations has the same results as the physical file system's
execution of the same ACL operations.  You could have a POSIX ACL
module, NTFS ACL module, etc.  There's a challenge for 4.2.

ACLs could possibly be made completely opaque to NFS with a module-based
approach.

  -Dan


> -----Original Message-----
> From: Ondrej Valousek [mailto:webserv@s3group.cz] 
> Sent: Wednesday, September 02, 2009 11:20 PM
> To: Steve French
> Cc: ffilzlnx@linux.vnet.ibm.com; linux-nfs@vger.kernel.org; 
> nfsv4@linux-nfs.org; Myklebust, Trond; jra@samba.org; agruen@suse.de
> Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
> 
> 
> > 2) If POSIX->NFSv4 client mapping is done (as had been 
> suggested IIRC 
> > by others in the past) at least you lose less data (NFSv4 
> ACLs are "richer"
> > in function than POSIX ACLs - so at least with the 
> POSIX->NFSv4->POSIX 
> > case you are limiting the user to the subset of choices which are 
> > actually going to be able to be stored, no inheritence etc.)
> >
> >   
> 
> I must say that I do not understand the motivation either. 
> POSIX is not even a standard and should be replaced with NFSv4 acls.
> Even now ext3/ext4 support NFSv4 acls (ok. patch is needed 
> but the patch is there already).
> 
> If the decision was up to me, I would forbid any nfsv4 acls 
> if the server can not store them properly (i.e. without any 
> conversion) + forbid using nfsv4 with posix acls over 
> sideband protocol (no standard, so netapp will never support 
> this and the same is to be expected from Windows and 
> Solaris). This is just adding mess and confusion.
> 
> My 5 cents...
> Ondrej
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> 
