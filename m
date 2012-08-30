Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45708 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab2H3GpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Aug 2012 02:45:07 -0400
Received: by eekc1 with SMTP id c1so539026eek.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Aug 2012 23:45:05 -0700 (PDT)
Message-ID: <503F0BEF.4020104@eneotecnologia.com>
Date: Thu, 30 Aug 2012 08:45:03 +0200
From: =?UTF-8?B?Q2FybG9zIEppbcOpbmV6?= <cjimenez@eneotecnologia.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Stale NFS file handle - persistent error
References: <503E131F.2040904@eneotecnologia.com> <503E13BF.6010304@eneotecnologia.com> <20120829171122.GA9983@fieldses.org>
In-Reply-To: <20120829171122.GA9983@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Thank you for your reply.
> Could you be more specific?  What kernel version exactly, and what
> filesystem are you exporting, and what are the export options?
Kernel version: 2.4.27-3-386
Filesystem exported: ext3
Export options: rw,no_root_squash,sync

I've shared/exported to the full network 192.168.180.0/24.
The exported directory is /opt/virtual/one and in /opt/virtual it is 
mounted /dev/cciss/c0d0p4 (with default options), which is a 256GB (8GB 
used) partition over a 3 disks RAID5.

>
> What version of NFS are you using?
>
Vers 3

> I assume you're not doing anything else with either file or directory at
> the same time?  (E.g., not deleting or renaming the file while it's
> being copied?)
>
>
I'm not doing anything else with either file or directory at the same time.

