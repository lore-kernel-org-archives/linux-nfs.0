From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mail corruption with async mounts NFSv3
Date: Tue, 11 Mar 2008 17:51:36 -0400
Message-ID: <FB63987D-5C83-4666-863E-3986251BB261@oracle.com>
References: <200803111859.m2BIxiKC001883@cs.utexas.edu> <20080311203337.GA22478@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Fletcher Mattox <fletcher-NZpS4cJIG2HvQtjrzfazuQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42474 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbYCKVxV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 17:53:21 -0400
In-Reply-To: <20080311203337.GA22478@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 11, 2008, at 4:33 PM, J. Bruce Fields wrote:
> On Tue, Mar 11, 2008 at 01:59:43PM -0500, Fletcher Mattox wrote:
>> We use NFSv3 on a 2.6.19.1 kernel with this entry in /etc/mtab:
>>
>>     filer4b:/vol/vol18/v18q001 /v/filer4b/v18q001 nfs \
>>       rw,tcp,rsize=8192,wsize=8192,intr,grpid,quota,retry=2,\
>>       addr=128.83.x.x 0 0
>>
>> I will admit to being surprised to learn that async mounts are the
>> default.  I was fooled by the absence of an "async" above.  Could  
>> that
>> be the problem?  I guess if the corruption were infrequent, isolated
>> events, I would be tempted to write it off to async an async mount.
>> But this happens consistently (several times a day on a 12,000
>> message/day mail server).
>
> You're probably confusing the "async" mount option with the "async"
> export option which the linux nfs server supports.  The latter is  
> unsafe
> and can lead to data corruption after server reboots.  The former  
> should
> be safe.
>
>>
>> We can identify no changes on the client or server which might  
>> account
>> for this.  Very frustrating.  Even a complete backup/restore on the
>> client from a couple weeks prior to the first reported incident had
>> no effect.  And our NetApp administrator tells me nothing changed on
>> the server.
>>
>> I am not a NetApp administrator, but looking at the server side,
>> I find this in NetApp's documentation (Solution ID: ntapcs6821),
>> wherein it states:
>>
>>         NetApp filers only support synchronous mounts. If
>>         an NFS client is mounted to a filer volume or qtree
>>         asynchronously, the client may or may not mount the
>>         filer volume. If the mount is successful, the NFS
>>         mount to the filer will be synchronous.
>>           [ ... snip ... ]
>>         * Using an asynchronous NFS mount could lead to data
>>           inconsistency or corruption
>
> So I'm confused by this documentation.  There isn't any way for the
> client to request behavior equivalent to the linux server's "async"
> behavior.

The documentation is poorly worded.  It refers to UNSTABLE writes --  
NetApp filers turn all NFSv3 write requests into FILE_SYNC writes.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



