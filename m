From: Ric Wheeler <ricwheeler@gmail.com>
Subject: Re: Very Slow Sequential Reads over NFS from an XFS disk in Amazon
 EC2
Date: Fri, 12 Mar 2010 13:30:49 -0500
Message-ID: <4B9A8859.6060503@gmail.com>
References: <e2c9b7261003111340i4aeff44dye0c5e9928ca13dc6@mail.gmail.com> <e2c9b7261003121022p40a5c382r3b0ca65e91d02622@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Brandon Simmons <brandon.m.simmons@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:49059 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934119Ab0CLSa7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Mar 2010 13:30:59 -0500
Received: by qw-out-2122.google.com with SMTP id 9so307749qwb.37
        for <linux-nfs@vger.kernel.org>; Fri, 12 Mar 2010 10:30:59 -0800 (PST)
In-Reply-To: <e2c9b7261003121022p40a5c382r3b0ca65e91d02622-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2010 01:22 PM, Brandon Simmons wrote:
> I am using tiobench to test performance of an NFS mounted volume, and
> notice that Sequential Reads are much slower than Random Reads. This
> isn't the behavior when I run the same test on the disk mounted
> locally.
>
> For random reads I'm getting:
>
>     50 MB/s  over NFS
>
> v.s
>
>     384 MB/s  when mounted locally
>
> This is in comparison to the benchmark for _Random Reads_, in which I get:
>
>     288 MB/s both over NFS _and_ when directly mounted
>
> The other benchmarks seem to be in line with what I would expect, but
> I'm fairly new to NFS. Why would sequential reads over NFS be sooo
> much slower than random reads over NFS?
>
> I am exporting the volume on the server like this
>
> /export *.internal(no_subtree_check,rw,no_root_squash)
>
> and mounting with this:
>
> mount -o hard,intr,async,noatime,nodiratime,noacl $NFS_SERVER:/export /nfs
>
> Additionally I am doing all this in amazon EC2, exporting an EBS
> volume with the XFS file system (redundant, I know).
>
> I have tried using jumbo frames and various other mount options, but
> none seem to have much effect.
>
> Thanks for any clues.
>    

Not sure what kind of network you are running the NFS test over so it is 
quite hard to figure out why your performance varies so wildly.

Normal NFS testing with a gigabit network between the client and server 
would be much closer to 50MB/sec than your 288MB/sec.

Can you try to reproduce this locally with known client and server hardware?

ric

