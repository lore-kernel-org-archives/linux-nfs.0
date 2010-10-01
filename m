From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: Re: Updated pNFS Developmental kernel repository
Date: Fri, 01 Oct 2010 15:51:00 +0200
Message-ID: <4CA5E744.9010006@desy.de>
References: <4CA5C059.6000805@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:35519 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805Ab0JANvZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 09:51:25 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 5F3CD1786
	for <linux-nfs@vger.kernel.org>; Fri,  1 Oct 2010 15:51:24 +0200 (MEST)
Received: from adserv72.win.desy.de (adserv72.win.desy.de [131.169.97.58])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 5604B13F26
	for <linux-nfs@vger.kernel.org>; Fri,  1 Oct 2010 15:51:24 +0200 (MEST)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by adserv72.win.desy.de
 (Clearswift SMTPRS 5.3.4) with ESMTP id <T9874e660e283a9613afa8-5mtNOt3R2DyEutHAMwCrcgxv4HzkJkzx@public.gmane.org> for <linux-nfs@vger.kernel.org>;
 Fri, 1 Oct 2010 15:51:24 +0200
Received: from [131.169.185.68] (anahit.desy.de [131.169.185.68])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id E6B0411E0
	for <linux-nfs@vger.kernel.org>; Fri,  1 Oct 2010 15:51:23 +0200 (MEST)
In-Reply-To: <4CA5C059.6000805-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Steve,

thanks for the builds. What I am missing is modprobe configuration file
which I have to add myself.

thanks,
    Tigran.

On 10/01/2010 01:04 PM, Steve Dickson wrote:
> Hello,
>
> I've updated the Fedora pNFS development repository to include the
> Fedora 13, 14 and Devel kernels that have the latest pNFS bits:
>
>      Tag: pnfs-all-2.6.35-2010-09-14     for Fedora 13 and 14 kernels
>      Tag: pnfs-all-latest                for Devel/f15 kernels
>
> (Note: there are also kernel-debuginfo and kernel-devel rpms for people who
> use things like systemtap probes and crash).
>
> I have not updated the nfs-utils rpms because I'm waiting
> for a fix to a problem in rpc.mountd. Once the problem is resolve
> I'll update those rpms as well...
>
> Instructions on how to install and use these kernels are at:
> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
>
>   If/when bugs are found with these rpms please enter them
> in to the NFS Bugzilla Main Page at:
>      https://bugzilla.linux-nfs.org/index.cgi
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

