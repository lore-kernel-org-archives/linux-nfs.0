From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Thu, 26 Jun 2008 13:42:58 -0400
Message-ID: <62137472-FF31-40A2-904D-A9CC2C76B032@oracle.com>
References: <OFA5778CCB.84AF3576-ON65257474.0027EF21-65257474.00283248@in.ibm.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34647 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756579AbYFZRpA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2008 13:45:00 -0400
In-Reply-To: <OFA5778CCB.84AF3576-ON65257474.0027EF21-65257474.00283248@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 26, 2008, at 3:19 AM, Krishna Kumar2 wrote:
> Benny Halevy <bhalevy@panasas.com> wrote on 06/23/2008 06:10:40 PM:
>
>> Apparently the file is cached.  You needed to restart nfs
>> and remount the file system to make sure it isn't before reading it.
>> Or, you can create a file larger than your host's cache size so
>> when you write (or read) it sequentially, its tail evicts its head
>> out of the cache.  This is a less reliable method, yet creating a
>> file about 25% larger than the host's memory size should work for  
>> you.
>
> I did a umount of all filesystems and restart NFS before testing. Here
> is the result:
>
> Local:
>      Read:  69.5 MB/s
>      Write: 70.0 MB/s
> NFS of same FS mounted loopback on same system:
>      Read:  29.5 MB/s  (57% drop)
>      Write: 27.5 MB/s  (60% drop)
>
> The drops seems exceedingly high. How can I figure out the source of  
> the
> problem? Even if it is as general as to be able to state: "Problem  
> is in
> the NFS client code" or "Problem is in the NFS server code", or  
> "Problem
> can be mitigated by tuning" :-)

It's hard to say what might be the problem just by looking at  
performance results.

You can look at client-side NFS and RPC performance metrics using some  
prototype Python tools that were just added to nfs-utils.  The scripts  
themselves can be downloaded from:

    http://oss.oracle.com/~cel/Linux-2.6/2.6.25

but unfortunately they are not fully documented yet so you will have  
to approach them with an open mind and a sense of experimentation.

You can also capture network traces on your loopback interface to see  
if there is, for example, unexpected congestion or latency, or if  
there are other problems.

But for loopback, the problem is often that the client and server are  
sharing the same physical memory for caching data.  Analyzing your  
test system's physical memory utilization might be revealing.

Otherwise, you should always expect some performance degradation when  
comparing NFS and local disk.  50% is not completely unheard of.  It's  
the price paid for being able to share your file data concurrently  
among multiple clients.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
