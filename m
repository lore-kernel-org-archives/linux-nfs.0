Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:38838 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaCFUbg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 15:31:36 -0500
Received: by mail-ie0-f177.google.com with SMTP id rl12so3335680iec.36
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 12:31:36 -0800 (PST)
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <401365131-1394135790-cardhu_decombobulator_blackberry.rim.net-946296583-@b5.c4.bise6.blackberry>
Date: Thu, 6 Mar 2014 15:31:33 -0500
Cc: linux-nfs-owner@vger.kernel.org, Andrew Martin <amartin@xes-inc.com>,
        Jim Rees <rees@umich.edu>, Brown Neil <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Message-Id: <85B2F64E-D153-414D-942F-0193E56A4554@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306163721.0edfb498@notabene.brown> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <1028951407-1394132418-cardhu_decombobulator_blackberry.rim.net-599891631-@b5.c4.bise6.blackberry> <E22EB8B3-DE5E-4D39-8FFD-BA3F02276EFE@primarydata.com> <745494581-1394133289-cardhu_decombobulator_blackberry.rim.net-1805734207-@b5.c4.bise6.blackberry> <84CFBA83-C2FE-4AA1-92D7-C37EDFC75117@primarydata.com> <1494458922-1394134385-cardhu_decombobulator_blackberry.rim.net-1425882517-@b5.c4.bise6.blackberry> <5B3606E3-01F9-45C5-8733-B424AF5CB8CB@primaryd!
 ata.com> <401365131-1394135790-cardhu_decombobulator_blackberry.rim.net-946296583-@b5.c4.bise6.blackberry>
To: bhawley@luminex.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 14:56, Brian Hawley <bhawley@luminex.com> wrote:

> 
> Given that the systems typically have 16GB's, the memory available for cache is usually around 13GB.
> 
> Dirty writeback centisecs is set to 100, as is dirty expire centisecs (we are primarily a sequential access application).
> 
> Dirty ratio is 50 and dirty background ratio is 10. 

That means you can have up to 8GB to push out in one go. You can hardly blame NFS for being slow in that situation.
Why do you need to cache these writes so aggressively? Is the data being edited and rewritten multiple times in the page cache before you want to push it to disk?

> We set these to try to keep the data from cache always being pushed out.
> 
> No oopses.   Typically it would be due to an appliance or network connection to it going down.  At which point, we want to fail over to an alternative appliance which is serving the same data.    
> 
> It's unfortunate that when the i/o error is detected that the other packets can't just timeout right away with the i/o error.   After all, it's unlikely to come back, and if it does, you've lost that data that was cached.  I'd almost rather have all the i/o's that were cached up to the blocked one fail so I know there was a failure of some of the writes preceeding the one that blocked and got the i/o error.    This is the price we pay for using "soft" and it is an expected price.   Otherwise, we'd use "hard”.

Right, but the RPC layer does not know that these are all writes to the same file, and it can’t be expected to know why the server isn’t replying. For instance, I’ve known a single ‘unlink' RPC call to take 17 minutes to complete on a server that had a lot of cleanup to do on that file; during that time, the server was happy to take RPC requests for other files...


> -----Original Message-----
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Sender: linux-nfs-owner@vger.kernel.org
> Date:	Thu, 6 Mar 2014 14:47:48 
> To: <bhawley@luminex.com>
> Cc: Andrew Martin<amartin@xes-inc.com>; Jim Rees<rees@umich.edu>; Brown Neil<neilb@suse.de>; <linux-nfs-owner@vger.kernel.org>; <linux-nfs@vger.kernel.org>
> Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
> 
> 
> On Mar 6, 2014, at 14:33, Brian Hawley <bhawley@luminex.com> wrote:
> 
>> 
>> We do call fsync at synchronization points.
>> 
>> The problem is the write() blocks forever (or for an exceptionally long time on the order of hours and days), even with timeo set to say 20 and retrans set to 2.  We see timeout messages in /var/log/messages, but the write continues to pend.   Until we start doing repeated umount -f's.  Then it returns and has an i/o error.
> 
> How much data are you trying to sync? ‘soft’ won’t time out the entire batch at once. It feeds each write RPC call through, and lets it time out. So if you have cached a huge amount of writes, then that can take a while. The solution is to play with the ‘dirty_background_bytes’ (and/or ‘dirty_bytes’) sysctl so that it starts writeback at an earlier time.
> 
> Also, what is the cause of these stalls in the first place? Is the TCP connection to the server still up? Are any Oopses present in either the client or the server syslogs?
> 
>> -----Original Message-----
>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>> Date: Thu, 6 Mar 2014 14:26:24 
>> To: <bhawley@luminex.com>
>> Cc: Andrew Martin<amartin@xes-inc.com>; Jim Rees<rees@umich.edu>; Brown Neil<neilb@suse.de>; <linux-nfs-owner@vger.kernel.org>; <linux-nfs@vger.kernel.org>
>> Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
>> 
>> 
>> On Mar 6, 2014, at 14:14, Brian Hawley <bhawley@luminex.com> wrote:
>> 
>>> 
>>> Trond,
>>> 
>>> In this case, it isn't fsync or close that are not getting the i/o error.  It is the write().  
>> 
>> My point is that write() isn’t even required to return an error in the case where your NFS server is unavailable. Unless you use O_SYNC or O_DIRECT writes, then the kernel is entitled and indeed expected to cache the data in its page cache until you explicitly call fsync(). The return value of that fsync() call is what tells you whether or not your data has safely been stored to disk.
>> 
>>> And we check the return value of every i/o related command.
>> 
>>> We aren't using synchronous because the performance becomes abysmal.
>>> 
>>> Repeated umount -f does eventually result in the i/o error getting propagated back to the write() call.   I suspect the repeated umount -f's are working their way through blocks in the cache/queue and eventually we get back to the blocked write.    
>>> 
>>> As I mentioned previously, if we mount with sync or direct i/o type options, we will get the i/o error, but for performance reasons, this isn't an option.
>> 
>> Sure, but in that case you do need to call fsync() before the application exits. Nothing else can guarantee data stability, and that’s true for all storage.
>> 
>>> -----Original Message-----
>>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>>> Date: Thu, 6 Mar 2014 14:06:24 
>>> To: <bhawley@luminex.com>
>>> Cc: Andrew Martin<amartin@xes-inc.com>; Jim Rees<rees@umich.edu>; Brown Neil<neilb@suse.de>; <linux-nfs-owner@vger.kernel.org>; <linux-nfs@vger.kernel.org>
>>> Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
>>> 
>>> 
>>> On Mar 6, 2014, at 14:00, Brian Hawley <bhawley@luminex.com> wrote:
>>> 
>>>> 
>>>> Even with small timeo and retrans, you won't get i/o errors back to the reads/writes.   That's been our experience anyway.
>>> 
>>> Read caching, and buffered writes mean that the I/O errors often do not occur during the read()/write() system call itself.
>>> 
>>> We do try to propagate I/O errors back to the application as soon as the do occur, but if that application isn’t using synchronous I/O, and it isn’t checking the return values of fsync() or close(), then there is little the kernel can do...
>>> 
>>>> 
>>>> With soft, you may end up with lost data (data that had already been written to the cache but not yet to the storage).   You'd have that same issue with 'hard' too if it was your appliance that failed.  If the appliance never comes back, those blocks can never be written.
>>>> 
>>>> In your case though, you're not writing.  
>>>> 
>>>> 
>>>> -----Original Message-----
>>>> From: Andrew Martin <amartin@xes-inc.com>
>>>> Date: Thu, 6 Mar 2014 10:43:42 
>>>> To: Jim Rees<rees@umich.edu>
>>>> Cc: <bhawley@luminex.com>; NeilBrown<neilb@suse.de>; <linux-nfs-owner@vger.kernel.org>; <linux-nfs@vger.kernel.org>
>>>> Subject: Re: Optimal NFS mount options to safely allow interrupts and
>>>> timeouts on newer kernels
>>>> 
>>>>> From: "Jim Rees" <rees@umich.edu>
>>>>> Andrew Martin wrote:
>>>>> 
>>>>>> From: "Jim Rees" <rees@umich.edu>
>>>>>> Given this is apache, I think if I were doing this I'd use
>>>>>> ro,soft,intr,tcp
>>>>>> and not try to write anything to nfs.
>>>>> I was using tcp,bg,soft,intr when this problem occurred. I do not know if
>>>>> apache was attempting to do a write or a read, but it seems that
>>>>> tcp,soft,intr
>>>>> was not sufficient to prevent the problem.
>>>>> 
>>>>> I had the impression from your original message that you were not using
>>>>> "soft" and were asking if it's safe to use it. Are you saying that even with
>>>>> the "soft" option the apache gets stuck forever?
>>>> Yes, even with soft, it gets stuck forever. I had been using tcp,bg,soft,intr
>>>> when the problem occurred (on several ocassions), so my original question was
>>>> if it would be safe to use a small timeo and retrans values to hopefully 
>>>> return I/O errors quickly to the application, rather than blocking forever 
>>>> (which causes the high load and inevitable reboot). It sounds like that isn't
>>>> safe, but perhaps there is another way to resolve this problem?
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> 
>>> 
>>> _________________________________
>>> Trond Myklebust
>>> Linux NFS client maintainer, PrimaryData
>>> trond.myklebust@primarydata.com
>>> 
>> 
>> _________________________________
>> Trond Myklebust
>> Linux NFS client maintainer, PrimaryData
>> trond.myklebust@primarydata.com
>> 
> 
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

