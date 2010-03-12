From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Very Slow Sequential Reads over NFS from an XFS disk in Amazon
 EC2
Date: Fri, 12 Mar 2010 13:33:28 -0500
Message-ID: <1268418808.8154.7.camel@localhost.localdomain>
References: <e2c9b7261003111340i4aeff44dye0c5e9928ca13dc6@mail.gmail.com>
	 <e2c9b7261003121022p40a5c382r3b0ca65e91d02622@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Brandon Simmons <brandon.m.simmons@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56678 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934445Ab0CLSdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 13:33:37 -0500
In-Reply-To: <e2c9b7261003121022p40a5c382r3b0ca65e91d02622-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-03-12 at 13:22 -0500, Brandon Simmons wrote: 
> I am using tiobench to test performance of an NFS mounted volume, and
> notice that Sequential Reads are much slower than Random Reads. This
> isn't the behavior when I run the same test on the disk mounted
> locally.
> 
> For random reads I'm getting:
> 
>    50 MB/s  over NFS
> 
> v.s
> 
>    384 MB/s  when mounted locally
> 
> This is in comparison to the benchmark for _Random Reads_, in which I get:
> 
>    288 MB/s both over NFS _and_ when directly mounted
> 
> The other benchmarks seem to be in line with what I would expect, but
> I'm fairly new to NFS. Why would sequential reads over NFS be sooo
> much slower than random reads over NFS?

They're not usually. My guess is that this is an artifact of your test.
What is tiobench doing prior to the sequential read?

Trond

