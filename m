From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 11:24:56 -0500
Message-ID: <C50C4825-3B05-4475-A280-7649C336BEEE@oracle.com>
References: <20081109164132.GA19615@uio.no> <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com> <20081112133553.GA32294@uio.no>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:40965 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbYKLQ0H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:26:07 -0500
In-Reply-To: <20081112133553.GA32294-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2008, at 8:35 AM, Steinar H. Gunderson wrote:

> On Wed, Nov 12, 2008 at 01:00:27AM -0500, Chuck Lever wrote:
>> Keep an eye out for IPv6-related patches for nfs-utils.  The key is  
>> to
>> ensure IPv4 continues to work, especially on Debian which tracks
>> upstream nfs-utils closely.
>
> We don't plan to incorporate IPv6-specific patches before upstream  
> does (and
> lenny, our upcoming release, is not going to get libtirpc or  
> rpcbind). When
> upstream nfs-utils is ready, you can expect us to configure with
> --enable-ipv6 pretty quickly, though :-)

We need testing to ensure that the latest nfs-utils still works on  
legacy systems, built with --disable-ipv6 and no libtirpc.  So please  
do test my patches and report issues there.

> I still haven't had any success with nfsd on the server side in  
> Linux; it's a
> bit unclear to me what nfs-utils to use in particular.

Server side NFS doesn't have any user space IPv6 support yet.  The  
kernel in my tree supports NFSv4 service over IPv6, but I don't think / 
etc/exports supports IPv6 addresses yet.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
