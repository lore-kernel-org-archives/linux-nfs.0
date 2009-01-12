From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [basic] nfsd failing to start
Date: Mon, 12 Jan 2009 17:00:20 -0500
Message-ID: <20090112220020.GG1834@fieldses.org>
References: <87zlhxy102.fsf@newsguy.com> <20090112172418.GC24322@fieldses.org> <87vdskxmdc.fsf@newsguy.com> <766DB6AD-DAD2-4C33-B11C-28A0D638A9D2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbZALWAW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 17:00:22 -0500
In-Reply-To: <766DB6AD-DAD2-4C33-B11C-28A0D638A9D2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2009 at 04:29:48PM -0500, Chuck Lever wrote:
> On Jan 12, 2009, at 4:09 PM, Harry P wrote:
>> "J. Bruce Fields" <bfields@fieldses.org>
>> writes:
>>
>>>>  CONFIG_NFS_FS=m
>>>>  CONFIG_NFS_V3=y
>>>>  CONFIG_NFS_V3_ACL=y
>>>>  CONFIG_NFS_V4=y
>>>>  CONFIG_NFSD=m
>>>>  CONFIG_NFSD_V2_ACL=y
>>>>  CONFIG_NFSD_V3=y
>>>>  CONFIG_NFSD_V3_ACL=y
>>>>  CONFIG_NFSD_V4=y
>>>>  CONFIG_NFS_ACL_SUPPORT=m
>>>>  CONFIG_NFS_COMMON=y
>>>>  CONFIG_SUNRPC=m
>>>>  CONFIG_SUNRPC_GSS=m
>>>>  CONFIG_SUNRPC_REGISTER_V4=y
>>>
>>> From the config help test: "If you enable this option, you must run a
>>> portmapper daemon that supports rpcbind protocol version 4."
>>
>> Thanks, with your clue I commented all nfs and SunRPC 4 related lines
>> recompiled and rebooted... started up with no problems.
>
> Clearly, setting the Kconfig default to N is not enough to prevent this 
> problem.  I don't understand why this option is getting enabled without 
> any other intervention on the part of kernel builders.  Maybe we need to 
> update arch/defconfig?
>
> It's on my immediate to-do list to see if the compile-time and run-time 
> behavior in this area can be improved.

I'd certainly be happiest if we could just fall back on the earlier
rpcbind protocol version at runtime.

--b.
