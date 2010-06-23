From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Connectathon locking test fails over NFSv3 with EBUSY
Date: Wed, 23 Jun 2010 15:17:00 -0400
Message-ID: <4C225DAC.2090203@oracle.com>
References: <4C2108E7.6040909@oracle.com> <1277234232.3204.40.camel@heimdal.trondhjem.org> <4C224991.1040809@oracle.com> <BF3BB6D12298F54B89C8DCC1E4073D80017545B4@CORPUSMX50A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Staubach_Peter@emc.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:33663 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab0FWTRW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 15:17:22 -0400
In-Reply-To: <BF3BB6D12298F54B89C8DCC1E4073D80017545B4-1Zg0zMUlrbd9m/dOYFj4Yjjd7nCn89gW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/23/10 02:06 PM, Staubach_Peter@emc.com wrote:
> Perhaps the oprofile support is retaining an additional reference to the in-core
> inode which is causing the .nfsXXXX files to get created and is also delaying their
> removal?

The files do not appear in oprofiled's fd list (in /proc).  Killing the 
oprofiled process after the test finishes does make those files go away. 
  Just shutting down the profiler leaves oprofiled, so additionally 
killing the daemon appears to be necessary to finish the silly removal 
process.

These files are all executables (part of the connectathon suite), but I 
don't have the "profile user space binaries" checkbox selected.

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Wednesday, June 23, 2010 1:51 PM
> To: Trond Myklebust
> Cc: NFSv3 list
> Subject: Re: Connectathon locking test fails over NFSv3 with EBUSY
>
> On 06/22/10 03:17 PM, Trond Myklebust wrote:
>> On Tue, 2010-06-22 at 15:03 -0400, Chuck Lever wrote:
>>> It looks like the connectathon tests race with the removal of deleted
>>> files.  The actual lock test is successful, but when the scripts attempt
>>> to reset the test directory for another pass, the RMDIR fails because
>>> the directory is full of ".nfsxxx" files.
>>>
>>> Seems like RMDIR should wait for those silly deletes before trying to
>>> remove the parent directory.
>>>
>>> I've seen this with both 2.6.34 and 2.6.35-rc3 clients, and it happens
>>> nearly every time.
>>>
>>>
>>> Test #15 - Test 2nd open and I/O after lock and close.
>>> 	Parent: Second open succeeded.
>>> 	Parent: 15.0  - F_LOCK  [               0,          ENDING] PASSED.
>>> 	Parent: 15.1  - F_ULOCK [               0,          ENDING] PASSED.
>>> 	Parent: Closed testfile.
>>> 	Parent: Wrote 'abcdefghij' to testfile [ 0, 11 ].
>>> 	Parent: Read 'abcdefghij' from testfile [ 0, 11 ].
>>> 	Parent: 15.2  - COMPARE [               0,               b] PASSED.
>>>
>>> ** PARENT pass 1 results: 49/49 pass, 1/1 warn, 0/0 fail (pass/total).
>>>
>>> **  CHILD pass 1 results: 64/64 pass, 0/0 warn, 0/0 fail (pass/total).
>>> Congratulations, you passed the locking tests!
>>> ... Pass 2 ...
>>
>> Err... Any idea what kind of operations are causing the sillyrename to
>> happen? The locking tests in particular should _never_ have any
>> outstanding operations post-ULOCK.
>
> I've reproduced this by running several passes of all of the tests
> ("./server -a -N10") while oprofile is running.  Without oprofile
> running this seems to be nearly impossible to reproduce.
>
> When a pass finishes, the RMDIR of the test directory fails because
> there are .nfsxxx files left in the directory.  These .nfsxxx files are
> not eventually removed, they stay after the test fails.
>
> Looking at the network trace, I see the RENAME that creates the files
> but no REMOVE is issued for these files.  Somehow, the client is
> forgetting to remove them.  There are plenty of proper RENAME/REMOVE
> pairs in the trace, so maybe this is a race condition.
>
> I found the RENAMEs in the network trace for all the remaining .nfsxxx
> files.  The names are:
>
> op_unlk, stat, op_ren, op_chmod, dupreq, excltest, negseek, rename,
> holey, truncate, nfsidem, rewind, telldir, bigfile, bigfile2, freesp
>
> These look like files created during the special tests.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

