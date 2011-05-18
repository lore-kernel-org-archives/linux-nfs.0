Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55998 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057Ab1ERUaG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2011 16:30:06 -0400
Subject: Re: NFS: pnfs ipv6 and multipath parsing
Content-Type: text/plain; charset=us-ascii
From: Weston Andros Adamson <dros@netapp.com>
In-Reply-To: <74A7DF78-2AF3-43EA-978B-E53252045F04@netapp.com>
Date: Wed, 18 May 2011 16:29:49 -0400
Cc: trond@netapp.com, linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <955779EA-D374-4C9A-B260-5200E3C19F8F@netapp.com>
References: <1305748634-28348-1-git-send-email-dros@netapp.com> <AA6F9C64-8FDB-4B0A-B8CB-80AB4FA3D985@oracle.com> <74A7DF78-2AF3-43EA-978B-E53252045F04@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Some clarification:

If ipv6.ko can't be found, this patch will still try to connect to the v6 address, fail (EIO) and revert to the MDS.

In order to properly handle this, we need to handle errors on connect and try another multipath address.  
I feel that this is really part of the other "half" of the multipath work (actually using more than one address), which we will get to very soon and should be treated as a separate patch.  Unless there are objections...

-dros

On May 18, 2011, at 4:19 PM, Weston Andros Adamson wrote:

> Yeah, that should work too.  Like other parts of fs/nfs/, I relied on rpc_pton() to allow or disallow parsing ipv6 addresses.
> 
> -dros
> 
> On May 18, 2011, at 4:11 PM, Chuck Lever wrote:
> 
>> 
>> On May 18, 2011, at 3:57 PM, Weston Andros Adamson wrote:
>> 
>>> These two patches add support for IPv6 dataserver connectivity and 
>>> parsing all multipath addresses.
>>> 
>>> IPv6: basically same patch as before:
>>> - no longer calls kzalloc() while holding spinlock
>>> - i verified that everything works as expected when CONFIG_IPV6 is not defined
>> 
>> You'll also need to worry about when IPv6 is built in a kernel module, but ipv6.ko cannot be loaded.
>> 
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

