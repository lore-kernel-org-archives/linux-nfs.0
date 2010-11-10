Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756071Ab0KJOqA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 09:46:00 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oAAEjxEO002644
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 09:46:00 -0500
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id oAAEjxob012893
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 09:45:59 -0500
Message-ID: <4CDAB027.8000202@RedHat.com>
Date: Wed, 10 Nov 2010 09:45:59 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Updated the pNFS Developmental Repository
References: <4CD9AC1A.707@RedHat.com>
In-Reply-To: <4CD9AC1A.707@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The repo is at http://steved.fedorapeople.org/repos/pnfs/
The repo file is at http://steved.fedorapeople.org/pnfs.repo

steved.

On 11/09/2010 03:16 PM, Steve Dickson wrote:
> Hello,
> 
> I've just updated the kernel and nfs-utils rpms in the pNFS development 
> repository to include:
>     * The latest nfs-utils release (pnfs-utils-1-2-4-rc1)
>     * The latest pNFS kernel bits (pnfs-all-2.6.36-2010-11-03)
> 
> Note: In this update there is only one kernel type (fc15)
> due to the fact both Fedora 13 and 14 are still on 2.6.35
> kernels which means the pnfs-all-2.6.36 patch will not apply 
> cleaning. I have booted this new kernel on both Fedora 13
> and 14 without issue... 
> 
> These nfs-utils rpms will now install the blkmapd init script
> and the /etc/modprobe.d/nfsv41.conf file which hopeful 
> get the correct modules installed on the client.
> 
> Instructions on how to install and use these kernels are at:
> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
> 
>  If/when bugs are found with these rpms please enter them
> in to the NFS Bugzilla Main Page at:
>     https://bugzilla.linux-nfs.org/index.cgi
> 
> Please use the "pNFS" keyword.. 
> 
> Any question or issues please feel free to contact me... 
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
