Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rhcavuit02.kulnet.kuleuven.be ([134.58.240.130]:37729 "EHLO
	cavuit02.kulnet.kuleuven.be" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750840AbaGBG6q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2014 02:58:46 -0400
Message-ID: <53B3AD97.1030403@esat.kuleuven.be>
Date: Wed, 02 Jul 2014 08:58:31 +0200
From: Rik Theys <Rik.Theys@esat.kuleuven.be>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS server caches client mount permissions?
References: <53B2B1AD.4080507@esat.kuleuven.be> <20140702122043.1c1c2c2d@notabene.brown>
In-Reply-To: <20140702122043.1c1c2c2d@notabene.brown>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On 07/02/2014 04:20 AM, NeilBrown wrote:
> On Tue, 01 Jul 2014 15:03:41 +0200 Rik Theys <Rik.Theys@esat.kuleuven.be>
> wrote:
>
>> Hi,
>>
>> We use NFS4 to export data to other clients. The exports file has the
>> directories exported to netgroups, for example:
>>
>> /export		@nfs(rw,async,no_subtree_check,fsid=0)
>> /export/data1	@nfs(rw,async,no_subtree_check)
>> /export/data2	@nfs(rw,async,no_subtree_check)
>>
>> If we forget to add a new client to the netgroup, the server rejects the
>> mount from the client (as it should). But when we then add the client to
>> the netgroup it can take up to 15 minutes for the server to accept the
>> new client.
>>
>> Using 'getent netgroup nfs' on the server immediately shows the new
>> entry of the client.
>>
>> Running exportfs -rv to reload the exports also doesn't help.
>>
>> Does nfsd cache mount access (rejections) somewhere? How can I
>> flush/tune this cache? Preferably without restarting the NFS server as
>> that causes a 90s interruption due to the grace period.
>
> Does
>    exportfs -f
>
> help?  It flushes the cache (which is normally updated ever 15 minutes).

In the meantime I've discovered the /proc/net/rpc/auth.unix.ip directory 
and learned that flushing the file fixes it.

I see now that's what exportfs -f does. Thanks! I'll use that command 
from now on instead of the script I created to flush the 
/proc/net/rpc/auth.unix.ip/content file.

Regards,

Rik


-- 
Rik Theys
System Engineer
KU Leuven - Dept. Elektrotechniek (ESAT)
Kasteelpark Arenberg 10 bus 2440  - B-3001 Leuven-Heverlee
+32(0)16/32.11.07
----------------------------------------------------------------
<<Any errors in spelling, tact or fact are transmission errors>>
