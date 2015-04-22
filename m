Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:51393 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756388AbbDVKlG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2015 06:41:06 -0400
Message-ID: <55376295.9060503@free.fr>
Date: Wed, 22 Apr 2015 10:57:57 +0200
From: Mason <slash.tmp@free.fr>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsroot protocol version
References: <551BC077.1030402@free.fr> <55360C4C.4010100@free.fr> <5EF1E689-1388-49A8-9DAD-F0078FC820DB@oracle.com> <55366287.6020105@free.fr> <A18103B0-EB7B-4336-95D6-4519F1279779@oracle.com>
In-Reply-To: <A18103B0-EB7B-4336-95D6-4519F1279779@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21/04/2015 17:16, Chuck Lever wrote:

> You might have better luck with this:
>
>   http://wiki.emacinc.com/wiki/Booting_with_an_NFS_Root_Filesystem
>
> It explains how to specify client kernel boot commandline parameters
> on your DHCP server that will make NFSROOT work.

Hello Chuck,

Thanks to you, it now works.

At first, I had mistakenly assumed U-boot was somehow passing the
root-path variable to Linux, but, in fact, Linux gets it from the
DHCP server (just like U-boot does).

Thus, if I set my boot command line to:
ip=dhcp root=/dev/nfs rdinit=/none console=ttyS0,115200 mem=640M

and if I change my DHCP server configuration to:
option root-path "172.27.64.1:/export/roots/6_2_0_8756,v3";

then everything works as expected, and my kernel no longer needs
to supportNFSv2.

Regards.

