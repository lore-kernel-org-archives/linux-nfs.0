Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:35430 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798Ab1LGOZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 09:25:05 -0500
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.2) with ESMTP id pB7DT4GA027281
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Wed, 7 Dec 2011 14:29:04 +0100
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id pB7DT3j0008645
	for <linux-nfs@vger.kernel.org>; Wed, 7 Dec 2011 14:29:03 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet2.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id pB7DT2oT012692
	for <linux-nfs@vger.kernel.org>; Wed, 7 Dec 2011 14:29:02 +0100
Message-ID: <4EDF6A1E.6020400@cea.fr>
Date: Wed, 07 Dec 2011 14:29:02 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Help wanted: ENOCLK returned during lock test#2 in connectathon's
 test
References: <4EDCCC89.6080205@cea.fr> <1323128020.7237.3.camel@lade.trondhjem.org> <4EDE0659.3060508@cea.fr> <20111206193747.GA11788@fieldses.org>
In-Reply-To: <20111206193747.GA11788@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Yes I am talking about the seqid inside the stateid.

    Philippe

J. Bruce Fields a écrit :
> On Tue, Dec 06, 2011 at 01:11:05PM +0100, DENIEL Philippe wrote:
>   
>> Hi Trond,
>>
>> many thanks for your reply.
>> In fact, the "rflag" in OP4_OPEN's reply is set to 6 = 4|2 =
>> OPEN4_RESULT_LOCKTYPE_POSIX|OPEN4_RESULT_CONFIRM
>> For some reason I do not understand, wireshark see
>> OPEN4_RESULT_LOCKTYPE_POSIX as an 'unknown' flag and do not print
>> it.  Bug actually it seems like OPEN4_RESULT_LOCKTYPE_POSIX is set.
>>
>> Your mail made me have a closer look to my implementation of
>> OP4_OPEN and OP4_OPEN_CONFIRM in NFSv4.0 . Since the beginning
>> (since I met this bug), I suspect something related to seqids : it
>> does not occur in NFSv4.1 where seqids 's management is made in
>> OP4_SEQUENCE, at the beginning of the request. So I ran lock test#2
>> on a kernel nfsd, capture the result and compared to what ganesha
>> produces. I saw a difference:
>> - when OP4_OPEN is invoked, the nfsd replies with a stateid
>> containing seqid=0. This seqid is passed to OP4_OPEN_CONFIRM which
>> confirms it and (if OK) replies with an updated stateid (seqid is
>> now 1)
>> - when ganesha does the same OP4_OPEN return a (unconfirmed) stateid
>> whose seqid is equal to 1, then OP4_OPEN_CONFIRM set this seqid to 2
>> when confirming the stateid.
>>     
>
> Sounds like you're talking about the seqid field that's contained in the
> stateid itself--I'd be suprised if the client cares about it.  The spec
> does allow the client to inspect that field to decide what order opens
> were done in, but other than that a client normally treats the whole
> stateid as opaque.
>
> --b.
>
>   
>> From your point of view, could this mess in seqid's management
>> produce the bug that I see when running lock test#2 ?
>>
>>    Regards
>>
>>       Philippe
>>
>> Trond Myklebust a écrit :
>>     
>>> On Mon, 2011-12-05 at 14:52 +0100, DENIEL Philippe wrote:
>>>       
>>>> Hi,
>>>>
>>>> as you may know (we may have met at Bake-A-Thon), I am working
>>>> on NFS-Ganesha, a NFS server running in userspace. I currently
>>>> face an issue when running cthon04 test suite, during the "lock
>>>> step".
>>>> Client is linux 3.1.0-rc4, server is nfs-ganesha compiled with
>>>> FSAL_VFS support. Server is mounted via command "mount
>>>> -overs=4.minorversion=1,lock <server>:<path> /mnt"
>>>>
>>>> During the test#2 in "lock" tests, I got the following error:
>>>>
>>>>    Creating parent/child synchronization pipes.
>>>>
>>>>    Test #2 - Try to lock the whole file.
>>>>            Parent: 2.0  - F_TLOCK [               0,          ENDING]
>>>>    FAILED!
>>>>            Parent: **** Expected success, returned errno=37...
>>>>            Parent: **** Probably implementation error.
>>>>
>>>>    ** PARENT pass 1 results: 0/0 pass, 0/0 warn, 1/1 fail (pass/total).
>>>>
>>>>    **  CHILD pass 1 results: 0/0 pass, 0/0 warn, 0/0 fail (pass/total).
>>>>
>>>>
>>>> I made a wireshark capture of the packet (see attachement).
>>>> Apparently, the client does 2 compounds, one for OP4_OPEN and a
>>>> second to call OP4_OPEN_CONFIRM.
>>>>         
>>> Hi Philippe,
>>>
>>> As far as I can see from the pcap file, your server isn't setting the
>>> OPEN4_RESULT_LOCKTYPE_POSIX flag in the OPEN reply, and so the client
>>> can't support posix locking semantics. In that case, it will return
>>> ENOLCK to all fcntl locking requests.
>>>
>>> Cheers
>>>  Trond
>>>       
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>     

