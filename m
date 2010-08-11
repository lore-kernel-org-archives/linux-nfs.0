Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49253 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757108Ab0HKUxt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Aug 2010 16:53:49 -0400
Subject: Re: Tuning NFS client write pagecache
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AANLkTi=+6c4CCWRbTYhXpG1YXW5Xb3u8OTL=auU7LOUZ@mail.gmail.com>
Date: Wed, 11 Aug 2010 14:51:49 -0600
Cc: "linux-nfs@vger.kernel.org Mailing list" <linux-nfs@vger.kernel.org>
Message-Id: <BEDD41A6-3E05-4784-8910-A04FEEB6EAD6@oracle.com>
References: <4C5BFE47.8020905@mxtelecom.com> <20100806132620.GA2921@merit.edu> <AANLkTin_pg7GCw9jcB2JK+0TbGu+MrQEcv4H_qAg_A3H@mail.gmail.com> <1281116260.2900.6.camel@heimdal.trondhjem.org> <AANLkTimArNXgDSJeHrqsdAhCQo_O0=bhRuqsQEp0ofN7@mail.gmail.com> <1281123565.2900.17.camel@heimdal.trondhjem.org> <AANLkTin7Q_X6Ovy3Q2XYqWUbNd57XauGsDQGekU=DSf1@mail.gmail.com> <98DC3FB9-72A7-44CF-AB8B-914F2379B01B@oracle.com> <0A97A441BFADC74EA1E299A79C69DF9213F109F3B2@orsmsx504.amr.corp.intel.com> <3DFB27D5-7AFE-4D03-AB35-9BCCBD5C6CA6@oracle.com> <AANLkTin-6OWetGMi-F7n3VnuJg0dh27tdN-C=jHR5hw+@mail.gmail.com> <1EDC250A-9F5E-4353-A78D-0A16B2612BBD@oracle.com> <AANLkTi=+6c4CCWRbTYhXpG1YXW5Xb3u8OTL=auU7LOUZ@mail.gmail.com>
To: Peter Chacko <peterchacko35@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug 11, 2010, at 11:14 AM, Peter Chacko wrote:
> We typically use 100MB/1GbE....and the server Storage is
> SATA/SCSI...for IOPs i have not really measured  the NFS client
> performance to tell you the exact number, and we use write size
> 4k/8ks...MTU size of the link is 1500 bytes...

> But we got noticeable uniform throughput(without a bursty traffic),
> and overall performance   when we hand-code NFS RPC
> operations(including MOUNT to get the root File handle) and send to
> server, that wrote all data to server at the NFS interface.(a sort of
> directNFS from the user space)..without going through kernel mode VFS
> interface of  NFS client driver. I was just wondering to get the same
> performance on native nfs client...

Again, I'm not hearing a clearly stated performance issue.

It doesn't sound like anything that can't easily be handled by the default mount options in any late model Linux distribution.  NFSv3 over TCP with the largest rsize and wsize negotiated with the server should easily handle this workload.

> Its still a matter of opinion about what  control we should give to
> applications and what OS should control.....!!
> 
> As we test more, i can send you more test data about this ..
> 
> Finally applications will end up re-invent the wheel to suits it
> special needs :-)

Given just this information, I don't see anything that suggests you can't implement all of this with POSIX system calls and the kernel NFS client.  Client-side data caching may waste a few resources for write-only and read-once workloads, but the kernel will reclaim memory when needed.  Your application can also use standard system calls to control the cached data, if it is a real concern.

> How does ORACLE's directNFS deal this ?

I work on the Linux kernel NFS client, so I can't really give dNFS specifics with any kind of authority.

dNFS is useful because the database already has its own built-in buffer cache, manages a very large resident set, and often needs tight cache coherency with other nodes in a database cluster (which is achieved via a separate cache protocol, rather than relying on NFS and OS caching behavior).

dNFS is logically quite similar to doing direct I/O through the kernel's NFS client.  The advantages of dNFS over direct I/O via the kernel are:

  1.  dNFS is a part of the Oracle database application, and thus the internal APIs and NFS behavior are always the same across all operating systems, and

  2.  dNFS allows a somewhat shorter code path and fewer context switches per I/O.  This is usually only critical on systems that require immense scaling.

I haven't heard anything, so far, that suggests your workload has these requirements.

> thanks chuck for your thoughts !
> 
> On Wed, Aug 11, 2010 at 9:35 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> [ Trimming CC: list ]
>> 
>> On Aug 10, 2010, at 8:09 PM, Peter Chacko wrote:
>> 
>>> Chuck,
>>> 
>>> Ok i will then check to see the command line option to request the DIO
>>> mode for NFS, as you suggested.
>>> 
>>> yes i other wise I fully understand the need of client caching.....for
>>> desktop bound or any general purpose applications... AFS, cacheFS are
>>> all good products in its own right.....but the only problem in such
>>> cases are cache coherence issues...(i mean other application clientss
>>> are not guaranteed to get the latest data,on their read) ..as NFS
>>> honor only open-to-close session semantics.
>>> 
>>> The situation i have is that,
>>> 
>>> we have a data protection product, that has agents on indvidual
>>> servers and a  storage gateway.(which is an NFS mounted box). The only
>>> purpose of this box is to store all data, in a streaming write
>>> mode.....for all the data coming from 10s of agents....essentially
>>> this acts like a VTL target....from this node, to NFS server node,
>>> there is no data travelling in the reverse path (or from the client
>>> cache to the application).
>>> 
>>> THis is the only use we put NFS under....
>>> 
>>> For recovery, its again a streamed read...... we never updating the
>>> read data, or re-reading the updated data....This is special , single
>>> function box.....
>>> 
>>> What do you think the best mount options for this scenario ?
>> 
>> What is the data rate (both IOPS and data throughput) of both the read and write cases?  How large are application read and write ops, on average?  What kind of networking is deployed?  What is the server and clients (hardware and OS)?
>> 
>> And, I assume you are asking because the environment is not performing as you expect.  Can you detail your performance issues?
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



