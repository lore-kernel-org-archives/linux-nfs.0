Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:47566 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab2BWMug (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 07:50:36 -0500
Message-ID: <4F463604.70204@steve-ss.com>
Date: Thu, 23 Feb 2012 13:50:12 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: tao.peng@emc.com
CC: linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
References: <4F40053A.3090301@steve-ss.com> <4F412E2F.9070200@steve-ss.com> <4F45E78E.8050501@steve-ss.com> <F19688880B763E40B28B2B462677FBF805EA5FFC82@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805EA5FFC82@MX09A.corp.emc.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/23/2012 09:33 AM, tao.peng@emc.com wrote:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of steve
>> Sent: Thursday, February 23, 2012 3:15 PM
>> To: linux-nfs@vger.kernel.org
>> Subject: Re: POSIX acls over nfs4
>>
>> Hi everyone
>> I'm sorry to bump this but I've tried the opensuse, ubuntu and samba
>> lists without any luck.
> Not reading the details in your setup, but maybe following summary can help you a bit.
> http://www.suse.de/~agruen/acl/linux-acls/online/
>
> Cheers,
> Tao
Hi
Thanks for the link.

I used nfs4_setfacl to set the share to group rw. The acl works on the 
unmounted ext4 folder (files created in the share become -rw-rw-) but 
does not work when the share wen mounted via nfs4. Could this be a bug?
Thanks,
Steve


