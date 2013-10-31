Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330Ab3JaUyq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 16:54:46 -0400
Message-ID: <5272C397.6020201@redhat.com>
Date: Thu, 31 Oct 2013 13:54:47 -0700
From: Anand Avati <aavati@redhat.com>
MIME-Version: 1.0
To: eshel@us.ibm.com, Linux NFS list <linux-nfs@vger.kernel.org>,
        nfsv4@ietf.org, nfsv4-bounces@ietf.org,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: XATTRs in NFS
References: <OF7DBE5533.A67587D8-ON88257C12.007C1560-88257C12.007CA986@us.ibm.com> <5272742D.7000905@redhat.com>
In-Reply-To: <5272742D.7000905@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> -------- Original Message --------
> Subject:     XATTRs in NFS
> Date:     Mon, 28 Oct 2013 15:41:37 -0700
> From:     Marc Eshel <eshel@us.ibm.com>
> To:     Marc Eshel <eshel@us.ibm.com>
> CC:     Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
> nfsv4@ietf.org, nfsv4-bounces@ietf.org
>
>
>
> This is a clean start to discuss extended attributes over NFS in the
> mailing list first.
>
> 1. What are the requirements and why? which applications are using them
> and how.

Reiterating, one of the applications (glusterfs - a distributed 
filesystem) has been using filesystems with extended attribute support 
by annotating files and dirs with crucial info for its operation (uses 
xattrs as a dumb key/value store). Usage of xattrs is crucial for the 
operation as glusterfs avoids using any sort of "external" meta-data 
database or metadata server for its operation (as a philosophy/design 
principle focused on robustness). Lack of xattrs on NFS prevents using 
NFS volumes as gluster bricks.

To that end, if NFS can map user.XXX values to user.XXX named attributes 
and vice versa in the NFS client and NFS server respectively, that would 
make NFS volumes be usable as gluster bricks.

> 2. Why are current named attributes in NFS not the right answer.

I think they might be, if we can map user.XXXX xattrs to named 
attributes and avoid any sort of interpretation of they key/values by 
NFS. Though from my point of view, all I care is for getxattr/setxattr 
of user.XXX keys to "just work" (whether they are mapped to named 
attributes or implemented as a separate feature).

Avati

> 3. What does the new protocol enhancements should look like?
>
> Thanks, Marc.
>


