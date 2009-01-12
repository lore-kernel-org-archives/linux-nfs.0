Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17059 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbZALV37 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2009 16:29:59 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <766DB6AD-DAD2-4C33-B11C-28A0D638A9D2@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
In-Reply-To: <87vdskxmdc.fsf@newsguy.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [basic] nfsd failing to start
Date: Mon, 12 Jan 2009 16:29:48 -0500
References: <87zlhxy102.fsf@newsguy.com> <20090112172418.GC24322@fieldses.org> <87vdskxmdc.fsf@newsguy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 12, 2009, at 4:09 PM, Harry P wrote:
> "J. Bruce Fields" <bfields@fieldses.org>
> writes:
>
>>>  CONFIG_NFS_FS=m
>>>  CONFIG_NFS_V3=y
>>>  CONFIG_NFS_V3_ACL=y
>>>  CONFIG_NFS_V4=y
>>>  CONFIG_NFSD=m
>>>  CONFIG_NFSD_V2_ACL=y
>>>  CONFIG_NFSD_V3=y
>>>  CONFIG_NFSD_V3_ACL=y
>>>  CONFIG_NFSD_V4=y
>>>  CONFIG_NFS_ACL_SUPPORT=m
>>>  CONFIG_NFS_COMMON=y
>>>  CONFIG_SUNRPC=m
>>>  CONFIG_SUNRPC_GSS=m
>>>  CONFIG_SUNRPC_REGISTER_V4=y
>>
>> From the config help test: "If you enable this option, you must run a
>> portmapper daemon that supports rpcbind protocol version 4."
>
> Thanks, with your clue I commented all nfs and SunRPC 4 related lines
> recompiled and rebooted... started up with no problems.

Clearly, setting the Kconfig default to N is not enough to prevent  
this problem.  I don't understand why this option is getting enabled  
without any other intervention on the part of kernel builders.  Maybe  
we need to update arch/defconfig?

It's on my immediate to-do list to see if the compile-time and run- 
time behavior in this area can be improved.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



