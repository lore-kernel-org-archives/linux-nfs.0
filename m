Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet14.oracle.com ([148.87.113.126]:40752 "EHLO
	rcsinet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab0JMBUS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 21:20:18 -0400
Received: from rcsinet10.oracle.com (rcsinet10.oracle.com [148.87.113.121])
	by rcsinet14.oracle.com (Sentrion-MP-4.0.0/Sentrion-MP-4.0.0) with ESMTP id o9CLKKh4003311
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 21:20:20 GMT
Subject: Re: whither NFS umount?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101012165040.39852c8d@corrin.poochiereds.net>
Date: Tue, 12 Oct 2010 17:19:11 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7A0E248F-125A-4117-8140-290718E68998@oracle.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com> <1286903046.24878.13.camel@heimdal.trondhjem.org> <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com> <20101012151826.76b75f52@corrin.poochiereds.net> <1286912649.1956.19.camel@heimdal.trondhjem.org> <20101012155234.094a87c3@corrin.poochiereds.net> <1286914860.3166.10.camel@heimdal.trondhjem.org> <20101012162625.074f7292@corrin.poochiereds.net> <C6938516-D27B-4D1D-93E1-AF37EB920DD5@oracle.com> <20101012165040.39852c8d@corrin.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 12, 2010, at 4:50 PM, Jeff Layton wrote:

> On Tue, 12 Oct 2010 16:34:45 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Oct 12, 2010, at 4:26 PM, Jeff Layton wrote:
>> 
>>> On Tue, 12 Oct 2010 16:21:00 -0400
>>> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>>> 
>>>> On Tue, 2010-10-12 at 15:52 -0400, Jeff Layton wrote:
>>>>> On Tue, 12 Oct 2010 15:44:09 -0400
>>>>> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>>>>> 
>>>>>> On Tue, 2010-10-12 at 15:18 -0400, Jeff Layton wrote:
>>>>>> 
>>>>>>> I think the part that causes problems is having userspace do this. In
>>>>>>> theory, if the kernel were in charge of sending the UMNT, then it's not
>>>>>>> really a problem since it knows when to do it. If we have code that
>>>>>>> sends a UMNT already, why not do a best-effort UMNT call from the
>>>>>>> kernel when we tear down the sb?
>>>>>> 
>>>>>> Purely for the pleasure of allowing the server to maintain inaccurate
>>>>>> statistics about who is currently mounting what? I think not...
>>>>>> 
>>>>>> You can get far more accurate results by replacing the MNT/UMNT state
>>>>>> counter with a purely server-based scheme to track who accessed one or
>>>>>> more files on each exported partition in the past 5 minutes or so. That
>>>>>> would even work with NFSv4...
>>>>>> 
>>>>> 
>>>>> True, but for better or worse, UMNT is part of the protocol. It seems
>>>>> like we ought to do our best to implement it, even if it is
>>>>> fundamentally flawed.
>>>>> 
>>>> 
>>>> UMNTALL is part of the same protocol, and yet we have never implemented
>>>> that. Just because something is documented, it doesn't mean we have to
>>>> do it...
>>>> 
>>>> The bottom line is that UMNT doesn't do what it advertises itself as
>>>> doing, and so we should not waste space supporting it in the kernel. We
>>>> shouldn't do so in userspace either.
>>>> 
>>> 
>>> Fair enough. Like Chuck I don't have strong feelings about it, other
>>> than seeing no need to continue shipping umount.nfs.
>> 
>> Careful... we still need umount.nfs, which is a link to mount.nfs.  Something in user space has to kick off local namespace changes, even if the server isn't affected.
>> 
> 
> Most other filesystems don't need a umount helper. If there isn't one
> present then /bin/umount takes care of the umount() call and cleaning
> the entry out of /etc/mtab.
> 
> My understanding was that umount.nfs only existed because it was needed
> to handle the UMNT RPC. Without that, there's really no need for it.
> 
> ...or am I overlooking something?

umount.nfs still handles "users=" which has special behavior for NFS mounts, for example.  Does that matter?

-- 
chuck[dot]lever[at]oracle[dot]com




