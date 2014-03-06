Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:32965 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaCFJh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 04:37:59 -0500
Message-ID: <531841F3.10401@gmail.com>
Date: Thu, 06 Mar 2014 11:37:55 +0200
From: Ric Wheeler <ricwheeler@gmail.com>
MIME-Version: 1.0
To: bhawley@luminex.com, Andrew Martin <amartin@xes-inc.com>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts
 on newer kernels
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>  <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <338027154-1394050544-cardhu_decombobulator_blackberry.rim.net-1945813324-@b5.c4.bise6.blackberry>
In-Reply-To: <338027154-1394050544-cardhu_decombobulator_blackberry.rim.net-1945813324-@b5.c4.bise6.blackberry>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/05/2014 10:15 PM, Brian Hawley wrote:
> In my experience, you won't get the i/o errors reported back to the read/write/close operations.   I don't know for certain, but I suspect this may be due to caching and chunking to turn I/o matching the rsize/wsize settings; and possibly the fact that the peer disconnection isn't noticed unless the nfs server resets (ie cable disconnection isn't sufficient).
>
> The inability to get the i/o errors back to the application has been a major pain for us.
>
> On a lark we did find that repeated unmont -f's does get i/o errors back to the application, but isn't our preferred way.

The key to get IO errors promptly is to make sure you use fsync/fdatasync (and 
so on) when you hit those points in your application that are where you want to 
recover from if things crash, get disconnected, etc.

Those will push out the data from the page cache while your application is still 
around which is critical for any potential need to do recovery.

Note that this is not just an issue with NFS, any file system (including local 
file systems) normally completes the write request when the IO hits the page 
cache.  When that page eventually gets sent down to the permanent storage device 
(NFS server, local disk, etc), your process is potentially no longer around and 
certainly not waiting for IO errors in the original write call :)

To make this even trickier is that the calls like fsync() that persist data have 
a substantial performance impact, so you don't want to over-use them.  (Try 
writing a 1GB file with an fsync() before close and comparing that to writing a 
1GB file opened in O_DIRECT|O_SYNC mode for the worst case for example :))

Ric

