Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56828 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab2CXHC4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Mar 2012 03:02:56 -0400
MIME-Version: 1.0
In-Reply-To: <1332505002.20500.14.camel@lade.trondhjem.org>
References: <CAKX=r8A90b25VKXC1qtAota9DqDrj37xFT511DuvrZ=1Eux6Xw@mail.gmail.com>
	<20120323114913.GB24489@umich.edu>
	<1332505002.20500.14.camel@lade.trondhjem.org>
Date: Sat, 24 Mar 2012 16:02:55 +0900
Message-ID: <CAKYAXd9us6rA03NMk8af_-2FNEhm5BBA2=Qb4cJ+YsivBgQM2Q@mail.gmail.com>
Subject: Re: NFS: low read/stat performance on small files
From: Namjae Jeon <linkinjeon@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jim Rees <rees@umich.edu>, Vivek Trivedi <vtrivedi018@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "amit.sahrawat83@gmail.com" <amit.sahrawat83@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/3/23 Myklebust, Trond <Trond.Myklebust@netapp.com>:
> On Fri, 2012-03-23 at 07:49 -0400, Jim Rees wrote:
>> Vivek Trivedi wrote:
>>
>>   204800 bytes (200.0KB) copied, 0.027074 seconds, 7.2MB/s
>>   Read speed for 200KB file is 7.2 MB
>>
>>   104857600 bytes (100.0MB) copied, 9.351221 seconds, 10.7MB/s
>>   Read speed for 100MB file is 10.7 MB
>>
>>   As you see read speed for 200KB file is only 7.2MB/sec while it is
>>   10.7 MB/sec when we read 100MB file.
>>   Why there is so much difference in read performance ?
>>   Is there any way to achieve high read speed for small files ?
>>
>> That seems excellent to me.  204800 bytes at 11213252 per sec would be 18.2
>> msec, so your per-file overhead is around 9 msec.  The disk latency alone
>> would normally be more than that.
>
> ...and the reason why the performance is worse for the 200K file
> compared to the 100M one is easily explained.
>
> When opening the file for reading, the client has a number of
> synchronous RPC calls to make: it needs to look up the file, check
> access permissions and possibly revalidate its cache. All these tasks
> have to be done in series (you cannot do them in parallel), and so the
> latency of each task is limited by the round-trip time to the server.
>
> On the other hand, once you get to doing READs, the client can send a
> bunch of readahead requests in parallel, thus ensuring that the server
> can use all the bandwidth available to the TCP connection.
>
> So your result is basically showing that for small files, the proportion
> of (readahead) tasks that can be done in parallel is smaller. This is as
> expected.
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>

Dear Trond.
I agree your answer.
Thanks a lot for your specific explaination.
