From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Fwd: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 14:16:08 -0400
Message-ID: <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:28054 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594AbZHUSQz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 14:16:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I want to understand the server bug a little more.  I glanced over RFC  
2623 and didn't see anything specific.

Is it the case that only Linux NFSD does this, or do other servers do  
it?  In other words, is this a typical server response, and if so, is  
there a specific semantic attached to it?

If no list is provided, should the client assume that only AUTH_NONE  
and AUTH_SYS are supported, or instead, perhaps that the client can  
try to use any flavor?  In other words, if no list is provided, let  
the mount proceed no matter what was specified by sec= ?

Thanks for any clarification.

Begin forwarded message:

> From: Trond Myklebust <trond.myklebust@fys.uio.no>
> Date: August 20, 2009 10:36:11 PM GMT-04:00
> To: Wu Fengguang <fengguang.wu@intel.com>, "Mr. Charles Edward  
> Lever" <Chuck.Lever@oracle.com>
> Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org 
> >
> Subject: Re: mount.nfs: access denied by server
>
> On Fri, 2009-08-21 at 09:27 +0800, Wu Fengguang wrote:
>> On Thu, Aug 20, 2009 at 09:02:29PM +0800, Trond Myklebust wrote:
>>> On Thu, 2009-08-20 at 15:13 +0800, Wu Fengguang wrote:
>>>> Hi,
>>>>
>>>> After upgrading NFS client kernel to latest linux-next, NFS mount
>>>> failed:
>>>>
>>>>        # mount -t nfs pxe:/cc /cc
>>>>        mount.nfs: access denied by server while mounting pxe:/cc
>>>>
>>>>        # uname -a
>>>>        Linux hp 2.6.31-rc6-next-20090818 #61 SMP Thu Aug 20  
>>>> 14:46:10 CST 2009 x86_64 GNU/Linux
>>>>
>>>> However server log says OK:
>>>>
>>>>        Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated mount  
>>>> request from 192.168.11.6:973 for /cc (/cc)
>>>>        Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated unmount  
>>>> request from 192.168.11.6:974 for /cc (/cc)
>>>>
>>>> However-2: nfsroot can be mounted at boot time. Server kernel has  
>>>> always been 2.6.30.
>>>>
>>>> Any ideas?
>>>>
>>>> Thanks,
>>>> Fengguang
>>>
>>> Can you try again after enabling mount debugging on the NFS client?
>>>
>>> echo 512 > /proc/sys/sunrpc/nfs_debug
>>
>> I used 1024 and found the mount failed here in nfs_walk_authlist():
>>
>>        dfprintk(MOUNT, "NFS: server does not support requested auth  
>> flavor\ n");
>>        nfs_umount(request);
>
> Thanks Fengguang!
>
> Chuck, this looks like one of yours. Could it be that you are hitting
> the same Linux knfsd bug that Tom Haynes saw with a Solaris client?
> AFAICR, the problem was that existing nfs servers do not set a default
> auth flavour, and so you just have to try with auth_sys and see if it
> succeeds...
>
> Cheers
>  Trond
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



