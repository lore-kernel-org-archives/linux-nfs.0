Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f195.google.com ([209.85.212.195]:38222 "EHLO
	mail-vw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbZICNgm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2009 09:36:42 -0400
Received: by vws33 with SMTP id 33so652107vws.33
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2009 06:36:44 -0700 (PDT)
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
References: <4A9F6027.9050807@s3group.cz>
	 <7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
Date: Thu, 3 Sep 2009 08:36:44 -0500
Message-ID: <524f69650909030636g68706b09wa50ad91984407878@mail.gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
From: Steve French <smfrench@gmail.com>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Cc: Ondrej Valousek <webserv@s3group.cz>, ffilzlnx@linux.vnet.ibm.com,
        linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>, jra@samba.org,
        agruen@suse.de
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 3, 2009 at 2:46 AM, Muntz, Daniel<Dan.Muntz@netapp.com> wrote:
> I've always thought of NFS as a means for making physical file systems
> available across a network.  NFS having its own ACLs doesn't fit this
> model.  E.g., "NFS ACLs" will never be integrated into NTFS.  However, I
> could imagine NFS ACLs solving the general problem if they were to form
> a superset of the ACLs of exportable physical file systems

NFSv4 ACLs are similar to CIFS/NTFS ACLS. NFSv4 ACLs were
originally based on CIFS/NTFS ACLs so it would be reasonable
to export them from NTFS (although the SIDs (UUIDs) have to be mapped
to local Linux UIDs - we have user space code that can do this in Samba).
Note Samba server can map between the CIFS/NTFS and NFSv4
ACLs already and has for many years.

JRA on the Samba team and Andreas have done some good
presentations on the differences in ACL models, but other than
storing the "mask" or equivalent - POSIX ACLs can be thought of as
a subset of NFSv4/CIFS/NTFS ACLs



-- 
Thanks,

Steve
