Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.trendhosting.net ([195.8.117.5]:36095 "EHLO
        mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756528AbcLNT17 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2016 14:27:59 -0500
Subject: Re: improving NFS stability in next Debian release
To: linux-nfs@vger.kernel.org, 847681@bugs.debian.org
References: <4415ff5c-98c3-629d-aefd-a5e677688bbb@pocock.pro>
From: Daniel Pocock <daniel@pocock.pro>
Message-ID: <1786db90-cdec-7959-6897-f78245831f05@pocock.pro>
Date: Wed, 14 Dec 2016 20:27:41 +0100
MIME-Version: 1.0
In-Reply-To: <4415ff5c-98c3-629d-aefd-a5e677688bbb@pocock.pro>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Brief update on this issue: nfs-utils 1.3.4 is now in Debian sid

There is discussion about changes (e.g. going from svcgssd to gss-proxy)
in this bug, if anybody could add any comments it would be very welcome

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=847681



On 11/12/16 20:01, Daniel Pocock wrote:
> 
> 
> Hi all,
> 
> NFS was quite stable with previous Debian versions but in Jessie, the
> current stable release, it has been prone to crashes under load (kernel
> 3.16, bug report[1]).  A user also asked[2] about this on the
> linux-fsdevel list a few months ago.
> 
> With the next Debian release freeze approaching, what will it take to
> ensure a stable experience for NFS users?
> 
> Are there any known problems for NFS in the current Debian kernel[3]?
> 
> Which version of nfs-utils should be distributed?  The current package
> is quite old[4].
> 
> Debian jessie-backports contains a 4.7.9 kernel, should that be
> compatible with the nfs-utils package v1.2.8 and other related things in
> jessie?
> 
> Regards,
> 
> Daniel
> 
> 
> 1. http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=847549
> 2. http://www.spinics.net/lists/linux-fsdevel/msg98540.html
> 3. https://packages.qa.debian.org/l/linux.html
> 4. https://packages.qa.debian.org/n/nfs-utils.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
