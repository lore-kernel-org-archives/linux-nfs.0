Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:28986 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab0FWRvZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 13:51:25 -0400
Message-ID: <4C224991.1040809@oracle.com>
Date: Wed, 23 Jun 2010 13:51:13 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: Connectathon locking test fails over NFSv3 with EBUSY
References: <4C2108E7.6040909@oracle.com> <1277234232.3204.40.camel@heimdal.trondhjem.org>
In-Reply-To: <1277234232.3204.40.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/22/10 03:17 PM, Trond Myklebust wrote:
> On Tue, 2010-06-22 at 15:03 -0400, Chuck Lever wrote:
>> It looks like the connectathon tests race with the removal of deleted
>> files.  The actual lock test is successful, but when the scripts attempt
>> to reset the test directory for another pass, the RMDIR fails because
>> the directory is full of ".nfsxxx" files.
>>
>> Seems like RMDIR should wait for those silly deletes before trying to
>> remove the parent directory.
>>
>> I've seen this with both 2.6.34 and 2.6.35-rc3 clients, and it happens
>> nearly every time.
>>
>>
>> Test #15 - Test 2nd open and I/O after lock and close.
>> 	Parent: Second open succeeded.
>> 	Parent: 15.0  - F_LOCK  [               0,          ENDING] PASSED.
>> 	Parent: 15.1  - F_ULOCK [               0,          ENDING] PASSED.
>> 	Parent: Closed testfile.
>> 	Parent: Wrote 'abcdefghij' to testfile [ 0, 11 ].
>> 	Parent: Read 'abcdefghij' from testfile [ 0, 11 ].
>> 	Parent: 15.2  - COMPARE [               0,               b] PASSED.
>>
>> ** PARENT pass 1 results: 49/49 pass, 1/1 warn, 0/0 fail (pass/total).
>>
>> **  CHILD pass 1 results: 64/64 pass, 0/0 warn, 0/0 fail (pass/total).
>> Congratulations, you passed the locking tests!
>> ... Pass 2 ...
>
> Err... Any idea what kind of operations are causing the sillyrename to
> happen? The locking tests in particular should _never_ have any
> outstanding operations post-ULOCK.

I've reproduced this by running several passes of all of the tests 
("./server -a -N10") while oprofile is running.  Without oprofile 
running this seems to be nearly impossible to reproduce.

When a pass finishes, the RMDIR of the test directory fails because 
there are .nfsxxx files left in the directory.  These .nfsxxx files are 
not eventually removed, they stay after the test fails.

Looking at the network trace, I see the RENAME that creates the files 
but no REMOVE is issued for these files.  Somehow, the client is 
forgetting to remove them.  There are plenty of proper RENAME/REMOVE 
pairs in the trace, so maybe this is a race condition.

I found the RENAMEs in the network trace for all the remaining .nfsxxx 
files.  The names are:

op_unlk, stat, op_ren, op_chmod, dupreq, excltest, negseek, rename, 
holey, truncate, nfsidem, rewind, telldir, bigfile, bigfile2, freesp

These look like files created during the special tests.
