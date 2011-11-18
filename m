Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6155 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753442Ab1KROIv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 09:08:51 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "<tigran.mkrtchyan@desy.de>" <tigran.mkrtchyan@desy.de>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: server reboot recovery is broken with 3.1 (3.2?) with nfsv41
 clients
Date: Fri, 18 Nov 2011 14:08:25 +0000
Message-ID: <081C1E0B-795E-4138-B66A-479F73BB3AC5@netapp.com>
References: <CAGue13oSMCs=mSMHsX2f_=+Eqc3i3rG8vkq0rSnMTm_sqpwcnw@mail.gmail.com>
In-Reply-To: <CAGue13oSMCs=mSMHsX2f_=+Eqc3i3rG8vkq0rSnMTm_sqpwcnw@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 18, 2011, at 8:57 AM, Tigran Mkrtchyan wrote:

> Dear  nfs hackers,
> 
> it looks like with kernel 3.1 client cant recover from server reboots.
> The nfs mount hangs and there are no packages sent from a client to the server.
> This was IO with pnfs.


Hi Tigran

Is this an MDS reboot? DS reboot? 

Thanks

-->Andy
> 
> Regards,
>   Tigran.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

