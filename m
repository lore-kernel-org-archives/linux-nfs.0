Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754224Ab0EFTPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 May 2010 15:15:06 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o46JF68N009923
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 6 May 2010 15:15:06 -0400
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o46JF6io011512
	for <linux-nfs@vger.kernel.org>; Thu, 6 May 2010 15:15:06 -0400
Message-ID: <4BE31538.7010604@RedHat.com>
Date: Thu, 06 May 2010 15:15:04 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [pnfs] Updated pNFS Developmental kernel rpms
References: <4BDB417C.2090505@RedHat.com>
In-Reply-To: <4BDB417C.2090505@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please Note, I just added an pNFS enabled nfs-utils to these 
repositories... This nfs-utils rpm should be usable on 
all three Fedora versions... Please let me know
if this is not the case...

steved.

On 04/30/2010 04:45 PM, Steve Dickson wrote:
> Hello,
> 
> I've updated the Fedora pNFS development kernels to include 
> the latest pNFS tag release and added new kernel repository. 
> 
> The Fedora 13 kernels (kernel-2.6.33) were updated to
> the pnfs-all-2.6.33-2010-04-29 git tag. I realize that F-13
> distro is not yet fully released, but its close and with a little
> a bit of persuasion ;-) and F-13 kernel can be used on a F-12 box. 
> 
> I also added a Fedora devel (or rawhide) repository. This repository
> will contain the Fedora Rawhide kernel (kernel-2.6.34) which
> closely mirrors the mainstream kernel. This kernel was updated
> to the pnfs-all-2.6.34-rc5-2010-04-29 git tag.
> 
> There were no changes to the Fedora 12 (kernel-2.6.32) repository.
> 
> Instructions on how to install and use these kernels are at:
> 
> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
> (Thank you Mark Uddin, from EMC, for your initial input on this,
> the input was very helpful!)
>  
> If/when bugs are found with these rpms please enter them
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
