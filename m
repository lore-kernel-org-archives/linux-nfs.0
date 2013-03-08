Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:54922 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755096Ab3CHVCk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 16:02:40 -0500
Message-ID: <513A517F.2040501@canonical.com>
Date: Fri, 08 Mar 2013 15:00:47 -0600
From: Dave Chiluk <dave.chiluk@canonical.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 setattr null-terminates strings
References: <513A1BD1.6060709@canonical.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patch definitely fixes the null termination issue.  Hopefully that
is the only issue with AIX.

Thanks,
Dave.

On 03/08/2013 12:33 PM, Myklebust, Trond wrote:
> On Fri, 2013-03-08 at 11:11 -0600, Dave Chiluk wrote:
>> As of commit 57e62324e469e092ecc6c94a7a86fe4bd6ac5172, the SETATTR nfsv4
>> command now null terminates fattr_owner and fattr_owner_group.
>>
>> Here is an example excerpt from a tcpdump
>> Opcode: SETATTR (34)
>>     stateid
>>         [StateID Hash: 0xafa9]
>>         seqid: 0x00000000
>>         Data: 000000000000000000000000
>>     obj_attributes
>>         attrmask
>>             recc_attr: FATTR4_OWNER_GROUP (37)
>>                 fattr4_owner_group: groupname@domainname.com
>>                     length: 25
>>
>> This means that even though there are actually 24 characters in
>> groupname@domainname.com, we now send 24 characters + 1 null character.
>> Hence the total length of 25.  Previously the client would send just the
>> 24 characters and set length to 24.
>>
>> This isn't an issue for communication with other Linux machines, but it
>> is an issue for interaction with AIX machines.  As is discussed here.
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1101292
>>
>> I attempted to read the RFC available here
>> http://tools.ietf.org/html/rfc5661, but have not been able to find a
>> statement instructing one way or the other.
>>
>> So the question becomes, is it correct for linux to be sending this null
>> terminator when read against the RFC, or is it AIX's responsibility to
>> handle null-terminated strings?
> 
> The client is definitely in error here according to RFC3530. Please
> check if the attached patch fixes the issue for you.
> 
> Cheers
>   Trond
> 

