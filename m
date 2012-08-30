Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53481 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380Ab2H3QCI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Aug 2012 12:02:08 -0400
Message-ID: <503F8E7C.1030102@netapp.com>
Date: Thu, 30 Aug 2012 12:02:04 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: =?UTF-8?B?Q2FybG9zIEppbcOpbmV6?= <cjimenez@eneotecnologia.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: Stale NFS file handle - persistent error
References: <503E131F.2040904@eneotecnologia.com> <503E13BF.6010304@eneotecnologia.com> <20120829171122.GA9983@fieldses.org> <503F0BEF.4020104@eneotecnologia.com>
In-Reply-To: <503F0BEF.4020104@eneotecnologia.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/30/2012 02:45 AM, Carlos Jiménez wrote:
> Hi,
> 
> Thank you for your reply.
>> Could you be more specific?  What kernel version exactly, and what
>> filesystem are you exporting, and what are the export options?
> Kernel version: 2.4.27-3-386

2.4.27 is incredibly old, do you have access to the server and can you try a more recent kernel?

- Bryan

> Filesystem exported: ext3
> Export options: rw,no_root_squash,sync
> 
> I've shared/exported to the full network 192.168.180.0/24.
> The exported directory is /opt/virtual/one and in /opt/virtual it is mounted /dev/cciss/c0d0p4 (with default options), which is a 256GB (8GB used) partition over a 3 disks RAID5.
> 
>>
>> What version of NFS are you using?
>>
> Vers 3
> 
>> I assume you're not doing anything else with either file or directory at
>> the same time?  (E.g., not deleting or renaming the file while it's
>> being copied?)
>>
>>
> I'm not doing anything else with either file or directory at the same time.
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

