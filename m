Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58737 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703Ab0ICQWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 12:22:47 -0400
Message-ID: <4C8120D3.9040704@candelatech.com>
Date: Fri, 03 Sep 2010 09:22:43 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs] nfs:  Fix nfs_sockaddr_match_ipaddr6
References: <1283530511-20658-1-git-send-email-greearb@candelatech.com> <1D980EDC-301A-4B4D-97D3-037B96DBAF86@oracle.com>
In-Reply-To: <1D980EDC-301A-4B4D-97D3-037B96DBAF86@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/03/2010 09:17 AM, Chuck Lever wrote:
>
> On Sep 3, 2010, at 12:15 PM, Ben Greear wrote:
>
>> A typo caused this method not not actually compare the
>> two addresses passed in.  It returned true in almost all
>> cases instead.
>
>  From the perspective of the local logic, that looks correct.  Have you tried this with IPv6 mounts?  Notice any overall changes in behavior?

I noticed this when getting multiple NFS mounts to work with srcaddr=

The change fixed the problems I was seeing, but I haven't tested w/out
srcaddr= logic.  Might need to have two different NFS servers to do a good
test of this logic, and I'm not looking forward to setting up another
open-solaris box!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

