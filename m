From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] SUNRPC: Use short-hand IPv6 ANYADDR for RPCB_SET
Date: Fri, 26 Sep 2008 17:37:36 -0400
Message-ID: <9295097D-800D-4D39-8996-987F9987ED07@oracle.com>
References: <20080915212437.3939.82594.stgit@ellison.1015granger.net> <20080915212730.3939.35770.stgit@ellison.1015granger.net> <20080926212000.GB7138@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: okir@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:20906 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbYIZViA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 17:38:00 -0400
In-Reply-To: <20080926212000.GB7138@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at Sep 26, 2008, 5:20 PM, J. Bruce Fields wrote:
> On Mon, Sep 15, 2008 at 04:27:30PM -0500, Chuck Lever wrote:
>> Clean up: When doing an RPCB_SET, make the kernel's rpcb client use  
>> the
>> shorthand "::" for the universal form of the IPv6 ANY address.
>>
>> Without this patch, rpcbind will advertise:
>>
>>  0000:0000:0000:0000:0000:0000:0000:0000.x.y
>>
>> This is cosmetic only.  It cleans up the display of information from
>> /sbin/rpcinfo.
>
> Also applied.
>
>> + 	if (ipv6_addr_any(&address_to_register->sin6_addr))
>
> Nit: I fixed up some initial whitespace.  Checkpatch or git apply  
> should
> warn about this.

Checkpatch is my usual weapon of choice, but it's not an automated  
part of my workflow.  I guess this one got past me.

>
>
> --b.
>
>> +		snprintf(buf, sizeof(buf), "::.%u.%u",
>> +				port >> 8, port & 0xff);
>> +	else
>> +		snprintf(buf, sizeof(buf), NIP6_FMT".%u.%u",
>> +				NIP6(address_to_register->sin6_addr),
>> +				port >> 8, port & 0xff);
>> 	map->r_addr = buf;
>>
>> 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




