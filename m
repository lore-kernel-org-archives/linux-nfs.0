Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61991 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757847Ab0HKCJo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Aug 2010 22:09:44 -0400
Received: by fxm13 with SMTP id 13so1102626fxm.19
        for <linux-nfs@vger.kernel.org>; Tue, 10 Aug 2010 19:09:42 -0700 (PDT)
In-Reply-To: <3DFB27D5-7AFE-4D03-AB35-9BCCBD5C6CA6@oracle.com>
References: <4C5BFE47.8020905@mxtelecom.com>
	<20100806132620.GA2921@merit.edu>
	<AANLkTin_pg7GCw9jcB2JK+0TbGu+MrQEcv4H_qAg_A3H@mail.gmail.com>
	<1281116260.2900.6.camel@heimdal.trondhjem.org>
	<AANLkTimArNXgDSJeHrqsdAhCQo_O0=bhRuqsQEp0ofN7@mail.gmail.com>
	<1281123565.2900.17.camel@heimdal.trondhjem.org>
	<AANLkTin7Q_X6Ovy3Q2XYqWUbNd57XauGsDQGekU=DSf1@mail.gmail.com>
	<98DC3FB9-72A7-44CF-AB8B-914F2379B01B@oracle.com>
	<0A97A441BFADC74EA1E299A79C69DF9213F109F3B2@orsmsx504.amr.corp.intel.com>
	<3DFB27D5-7AFE-4D03-AB35-9BCCBD5C6CA6@oracle.com>
Date: Wed, 11 Aug 2010 07:39:42 +0530
Message-ID: <AANLkTin-6OWetGMi-F7n3VnuJg0dh27tdN-C=jHR5hw+@mail.gmail.com>
Subject: Re: Tuning NFS client write pagecache
From: Peter Chacko <peterchacko35@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jim Rees <rees@umich.edu>, Matthew Hodgson <matthew@mxtelecom.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

thanks GILLIiam for your message and Chuck for your detailed
explanation...out of your long term work with NFS.

Gilliam, most incremental backup systems use hashes/checksums to
determine the new data(deltas) not by reading all the data from the
server(or that data they wrote to the chache) but from a local
database that the backup agent keeps....rsync only requires fixed
length block checksums from the server, and it computes a rolling
checksums(weak and strong) on the clients and detect duplication....it
also doesn'r re-read the data at NFS level.


Chuck,

Ok i will then check to see the command line option to request the DIO
mode for NFS, as you suggested.

yes i other wise I fully understand the need of client caching.....for
desktop bound or any general purpose applications... AFS, cacheFS are
all good products in its own right.....but the only problem in such
cases are cache coherence issues...(i mean other application clientss
are not guaranteed to get the latest data,on their read) ..as NFS
honor only open-to-close session semantics.

The situation i have is that,

we have a data protection product, that has agents on indvidual
servers and a  storage gateway.(which is an NFS mounted box). The only
purpose of this box is to store all data, in a streaming write
mode.....for all the data coming from 10s of agents....essentially
this acts like a VTL target....from this node, to NFS server node,
there is no data travelling in the reverse path (or from the client
cache to the application).

THis is the only use we put NFS under....

For recovery, its again a streamed read...... we never updating the
read data, or re-reading the updated data....This is special , single
function box.....

What do you think the best mount options for this scenario ?

I greatly appreciate y your time explaining ..

Thanks
peter.



On Wed, Aug 11, 2010 at 3:17 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Aug 10, 2010, at 2:50 PM, Gilliam, PaulX J wrote:
>
>>
>>
>>> -----Original Message-----
>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>>> Sent: Tuesday, August 10, 2010 9:27 AM
>>> To: Peter Chacko
>>> Cc: Trond Myklebust; Jim Rees; Matthew Hodgson; linux-nfs@vger.kernel.org
>>> Subject: Re: Tuning NFS client write pagecache
>>>
>>>
>>> On Aug 6, 2010, at 9:15 PM, Peter Chacko wrote:
>>>
>>>> I think you are not understanding the use case of a  file-system wide,
>>>> non-cached IO for NFS.
>>>>
>>>> Imagine a case when a unix shell programmer  create a backup
>>>> script,who doesn't know C programming or system calls....he just wants
>>>> to use a  cp -R sourcedir  /targetDir.  Where targetDir is an NFS
>>>> mounted share.
>>>>
>>>> How can we use programmatical , per file-session interface to O_DIRECT
>>>> flag here ?
>>>>
>>>> We need a file-system wide direct IO mechanisms ,the best place to
>>>> have is at the mount time. We cannot tell all sysadmins to go and
>>>> learn programming....or backup vendors to change their code that they
>>>> wrote 10 - 12 years ago...... Operating system functionalities should
>>>> cover a large audience, with different levels of  training/skills.
>>>>
>>>> I hope you got my point here....
>>>
>>> The reason Linux doesn't support a filesystem wide option is that direct
>>> I/O has as much potential to degrade performance as it does to improve it.
>>> The performance degradation can affect other applications on the same file
>>> system and other clients connected to the same server.  So it can be an
>>> exceptionally unfriendly thing to do for your neighbors if an application
>>> is stupid or malicious.
>>
>> Please forgive my ignorance, but could you give a example or two?  I can understand how direct I/O can degrade the performance of the application that is using it.  But I can't see how other applications' performance would be affected.  Unless maybe it would increase the network traffic due to the lack of write consolidation.  I can see that:  many small writes instead of one larger one.
>
> Most typical desktop applications perform small writes, a lot of rereads of the same data, and depend on read-ahead for good performance.  Application developers assume a local data cache in order to keep their programs simple.  To get good performance, even on local file systems, their applications would have to maintain their own data cache (in fact, that is what direct I/O-enabled applications do already).
>
> Having no data cache on the NFS client means that all of this I/O would be exposed to the network and the NFS server.   That's an opportunity cost paid for by all other users of the network and NFS server.  Exposing that excess I/O activity will have a broad effect on the amount of I/O the system as whole (clients, network, server) can perform.
>
> If you have one NFS client running just a few apps, you may not notice the difference (unless you have a low bandwidth network).  But NFS pretty much requires good client-side caching to scale in the number of clients and amount of I/O.
>
>> I don't need details, just a couple of sketchy examples so I can visualize what you are referring to.
>>
>> Thanks for increasing my understanding,
>>
>> -=# Paul Gilliam #=-
>>
>>
>>> To make direct I/O work well, applications have to use it sparingly and
>>> appropriately.  They usually maintain their own buffer cache in lieu of the
>>> client's generic page cache.  Applications like shells and editors depend
>>> on an NFS client's local page cache to work well.
>>>
>>> So, we have chosen to support direct I/O only when each file is opened, not
>>> as a file system wide option.  This is a much narrower application of this
>>> feature, and has a better chance of helping performance in special cases
>>> while not destroying it broadly.
>>>
>>> So far I haven't read anything here that clearly states a requirement we
>>> have overlooked in the past.
>>>
>>> For your "cp" example, the NFS community is looking at ways to reduce the
>>> overhead of file copy operations by offloading them to the server.  The
>>> file data doesn't have to travel over the network to the client.  Someone
>>> recently said when you leave this kind of choice up to users, they will
>>> usually choose exactly the wrong option.  This is a clear case where the
>>> system and application developers will choose better than users who have no
>>> programming skills.
>>>
>>>
>>>> On Sat, Aug 7, 2010 at 1:09 AM, Trond Myklebust
>>>> <trond.myklebust@fys.uio.no> wrote:
>>>>> On Sat, 2010-08-07 at 00:59 +0530, Peter Chacko wrote:
>>>>>> Imagine a third party backup app for which a customer has no source
>>>>>> code. (that doesn't use open system call O_DIRECT mode) backing up
>>>>>> millions of files through NFS....How can we do a non-cached IO to the
>>>>>> target server ?  we cannot use O_DIRECT option here as we don't have
>>>>>> the source code....If we have mount option, its works just right
>>>>>> ....if we can have read-only mounts, why not have a dio-only mount ?
>>>>>>
>>>>>> A true application-Yaware storage systems(in this case NFS client) ,
>>>>>> which is the next generation storage systems should do, should absorb
>>>>>> the application needs that may apply to the whole FS....
>>>>>>
>>>>>> i don't say O_DIRECT flag is a bad idea, but it will only work with a
>>>>>> regular application that do IO to some files.....this is not the best
>>>>>> solution when NFS server is used as the storage for secondary data,
>>>>>> where NFS client runs third party applications thats otherwise run
>>>>>> best in a local storage as there is no caching issues....
>>>>>>
>>>>>> What do you think ?
>>>>>
>>>>> I think that we've had O_DIRECT support in the kernel for more than six
>>>>> years now. If there are backup vendors out there that haven't been
>>>>> paying attention, then I'd suggest looking at other vendors.
>>>>>
>>>>> Trond
>>>>>
>>>>>> On Fri, Aug 6, 2010 at 11:07 PM, Trond Myklebust
>>>>>> <trond.myklebust@fys.uio.no> wrote:
>>>>>>> On Fri, 2010-08-06 at 15:05 +0100, Peter Chacko wrote:
>>>>>>>> Some distributed file systems such as IBM's SANFS, support direct IO
>>>>>>>> to the target storage....without going through a cache... ( This
>>>>>>>> feature is useful, for write only work load....say, we are backing up
>>>>>>>> huge data to an NFS share....).
>>>>>>>>
>>>>>>>> I think if not available, we should add a DIO mount option, that tell
>>>>>>>> the VFS not to cache any data, so that close operation will not
>>> stall.
>>>>>>>
>>>>>>> Ugh no! Applications that need direct IO should be using
>>> open(O_DIRECT),
>>>>>>> not relying on hacks like mount options.
>>>>>>>
>>>>>>>> With the open-to-close , cache coherence protocol of NFS, an
>>>>>>>> aggressive caching client, is a performance downer for many work-
>>> loads
>>>>>>>> that is write-mostly.
>>>>>>>
>>>>>>> We already have full support for vectored aio/dio in the NFS for those
>>>>>>> applications that want to use it.
>>>>>>>
>>>>>>> Trond
>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> On Fri, Aug 6, 2010 at 2:26 PM, Jim Rees <rees@umich.edu> wrote:
>>>>>>>>> Matthew Hodgson wrote:
>>>>>>>>>
>>>>>>>>> Is there any way to tune the linux NFSv3 client to prefer to write
>>>>>>>>> data straight to an async-mounted server, rather than having large
>>>>>>>>> writes to a file stack up in the local pagecache before being
>>> synced
>>>>>>>>> on close()?
>>>>>>>>>
>>>>>>>>> It's been a while since I've done this, but I think you can tune
>>> this with
>>>>>>>>> vm.dirty_writeback_centisecs and vm.dirty_background_ratio sysctls.
>>> The
>>>>>>>>> data will still go through the page cache but you can reduce the
>>> amount that
>>>>>>>>> stacks up.
>>>>>>>>>
>>>>>>>>> There are other places where the data can get buffered, like the rpc
>>> layer,
>>>>>>>>> but it won't sit there any longer than it takes for it to go out the
>>> wire.
>>>>>>>>> --
>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>> in
>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>> in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>
>>>>>
>>>>>
>>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
