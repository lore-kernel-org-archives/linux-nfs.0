From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Reading NFS file without copying to user-space?
Date: Fri, 4 Sep 2009 18:00:26 -0400
Message-ID: <03767E4F-FF0C-4197-85C6-0222A4AB1FCE@fys.uio.no>
References: <4AA16F25.6050700@candelatech.com> <1252096543.2402.4.camel@heimdal.trondhjem.org> <4AA17D62.9020404@candelatech.com> <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no> <4AA182A2.5060507@candelatech.com>
Mime-Version: 1.0 (iPhone Mail 7A400)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47516 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934291AbZIDWAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 18:00:32 -0400
In-Reply-To: <4AA182A2.5060507@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 4, 2009, at 17:12, Ben Greear <greearb@candelatech.com> wrote:

> On 09/04/2009 01:58 PM, Trond Myklebust wrote:
>> On Sep 4, 2009, at 16:49, Ben Greear <greearb@candelatech.com> wrote:
>>
>>> I'm using O_DIRECT (so that the server is continually stressed  
>>> even if
>>> the file would have otherwise been cached locally on the client).
>>>
>>> This still causes a copy of the contents to user-space when I do a
>>> read() call though, as far as I can tell. Since I'm normally not  
>>> looking
>>> at this data at all, the memory copy from kernel to user is wasted
>>> effort in my case.
>>
>> You're missing the point. O_DIRECT does not copy data from the kernel
>> into userspace. The data is placed directly into the user buffer from
>> the socket.
>
> I may be going about things all wrong...
>
>>
>> The only faster alternative would be to directly discard the data  
>> in the
>> socket, and we offer no option to do that.
>
> I'm opening an fd like this:
>
>
>         uint32 flgs = O_RDONLY | O_DIRECT | O_LARGEFILE;
>         fd = open(fname, flgs);
>
> Then read from the fd it:
>         int retval = read(fd, rcv_buffer_ptr, my_read_len);
>
> rcv_buffer_ptr is just a 1MB (or so) array of bytes.
>

Use a (much) larger buffer. Linux clients are capable of reading 2MB  
in a single RPC, so you won't be doing much in the way of parallel  
reads with 1MB.
I'd also suggest bumping up the number of tcp slots (see in /proc/sys/ 
fs/nfs/). This should be done before you mount the NFS partition. 
