Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58359 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab0HKROU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Aug 2010 13:14:20 -0400
Received: by fxm13 with SMTP id 13so282169fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Aug 2010 10:14:19 -0700 (PDT)
In-Reply-To: <1EDC250A-9F5E-4353-A78D-0A16B2612BBD@oracle.com>
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
	<AANLkTin-6OWetGMi-F7n3VnuJg0dh27tdN-C=jHR5hw+@mail.gmail.com>
	<1EDC250A-9F5E-4353-A78D-0A16B2612BBD@oracle.com>
Date: Wed, 11 Aug 2010 22:44:19 +0530
Message-ID: <AANLkTi=+6c4CCWRbTYhXpG1YXW5Xb3u8OTL=auU7LOUZ@mail.gmail.com>
Subject: Re: Tuning NFS client write pagecache
From: Peter Chacko <peterchacko35@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "linux-nfs@vger.kernel.org Mailing list" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We typically use 100MB/1GbE....and the server Storage is
SATA/SCSI...for IOPs i have not really measured  the NFS client
performance to tell you the exact number, and we use write size
4k/8ks...MTU size of the link is 1500 bytes...

But we got noticeable uniform throughput(without a bursty traffic),
and overall performance   when we hand-code NFS RPC
operations(including MOUNT to get the root File handle) and send to
server, that wrote all data to server at the NFS interface.(a sort of
directNFS from the user space)..without going through kernel mode VFS
interface of  NFS client driver. I was just wondering to get the same
performance on native nfs client...

Its still a matter of opinion about what  control we should give to
applications and what OS should control.....!!

As we test more, i can send you more test data about this ..

Finally applications will end up re-invent the wheel to suits it
special needs :-)

How does ORACLE's directNFS deal this ?

thanks chuck for your thoughts !

On Wed, Aug 11, 2010 at 9:35 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> [ Trimming CC: list ]
>
> On Aug 10, 2010, at 8:09 PM, Peter Chacko wrote:
>
>> Chuck,
>>
>> Ok i will then check to see the command line option to request the DIO
>> mode for NFS, as you suggested.
>>
>> yes i other wise I fully understand the need of client caching.....for
>> desktop bound or any general purpose applications... AFS, cacheFS are
>> all good products in its own right.....but the only problem in such
>> cases are cache coherence issues...(i mean other application clientss
>> are not guaranteed to get the latest data,on their read) ..as NFS
>> honor only open-to-close session semantics.
>>
>> The situation i have is that,
>>
>> we have a data protection product, that has agents on indvidual
>> servers and a  storage gateway.(which is an NFS mounted box). The only
>> purpose of this box is to store all data, in a streaming write
>> mode.....for all the data coming from 10s of agents....essentially
>> this acts like a VTL target....from this node, to NFS server node,
>> there is no data travelling in the reverse path (or from the client
>> cache to the application).
>>
>> THis is the only use we put NFS under....
>>
>> For recovery, its again a streamed read...... we never updating the
>> read data, or re-reading the updated data....This is special , single
>> function box.....
>>
>> What do you think the best mount options for this scenario ?
>
> What is the data rate (both IOPS and data throughput) of both the read and write cases?  How large are application read and write ops, on average?  What kind of networking is deployed?  What is the server and clients (hardware and OS)?
>
> And, I assume you are asking because the environment is not performing as you expect.  Can you detail your performance issues?
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
