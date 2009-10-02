Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53532 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890AbZJBW7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2009 18:59:24 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <FED38E90-C32D-43E8-A0A2-5A37E4BB894F@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Tom Haynes <tdh@excfb.com>
In-Reply-To: <4AC67481.20900@excfb.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: mount retries
Date: Fri, 2 Oct 2009 18:59:19 -0400
References: <4AC67481.20900@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Oct 2, 2009, at 5:45 PM, Tom Haynes wrote:
> Does the Linux mount client have any algorithms to retry a NFS mount?
>
> Or does it depend entirely on the underlying protocol.
>
> I.e., would TCP retry and UDP just give up?

The behavior is pretty complex.

There's a large retry loop that can try mounts in the foreground, or  
automatically daemonize if the mount request isn't successful at  
first.  The retry loop continues as long as there are server or  
network problems that prevent a definitive answer from the server from  
getting back to the client.  There is a retry= mount option to cut off  
retrying after a certain amount of time.

If a particular NFS version or transport is requested by the user, it  
will attempt to use those settings, and fail if those aren't available  
on the server.  For v2/v3, any parameters not specified by the user,  
like port, transport, or version, are filled in with pmap queries.   
The choice of transport is a little odd; if the user didn't specify a  
transport, it looks like the transport that worked for the pmap query  
is chosen regardless of what is registered.  ie, if a TCP pmap query  
fails, but the UDP pmap query worked, we go with UDP, whether or not  
the NFS service is registered on UDP.

For v4, it skips the pmap query and just dives into the kernel to try  
connecting with the server.

If none of these work, and the mount command hasn't gotten a definite  
yes or no from the server (and all of the mount options are valid and  
legal) it will keep trying until it works, the user hits ^C, or the  
retry timer expires.  The ^C part doesn't apply to daemonized mounts.

The exact retry behavior depends on whether user space or the kernel  
is trying to do the talking.  NFSv4 and text-based NFSv2/v3 mounts do  
most of the talking from the kernel.  Text-based mounts do a user  
space pmap query or two, but the MNT request comes from the kernel.   
Also, UDP retries a few times, but usually gives up after 30 seconds  
or so, but TCP can retry the transport connect for over 3 minutes,  
even before it gets to send any requests at all.

I'm pretty sure I didn't answer your question.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



