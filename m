Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40987 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965851Ab0GPP40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 11:56:26 -0400
Message-ID: <4C4079CC.8070205@oracle.com>
Date: Fri, 16 Jul 2010 11:25:00 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Tom H <tom@limepepper.co.uk>
CC: linux-nfs@vger.kernel.org
Subject: Re: why do attempts to access a nfs v3 filesystem (ro,soft) block
 the process for minutes at a time? (when the nfs server is down)
References: <4C4078AE.5070300@limepepper.co.uk>
In-Reply-To: <4C4078AE.5070300@limepepper.co.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/16/2010 11:20 AM, Tom H wrote:
>
> (apologies for the cross post from the deprecated list)
>
> Hi all,
>
> I have a web server which serves some content from an nfs filesystem
> mounted like so;
> nfsserver1:/somemount /var/www/html/somefiles nfs rw,soft
> 0 0
>
> # mount | grep nfs
> nfsserver1:/somemount on /var/www/html/somefiles type nfs
> (ro,soft,addr=xx.xx.xx.xx)
>
> According to the documentation, an NFS operation on a soft mount should
> wait for a "major timeout" and then report "server not responding" to
> syslog and return an error. where a major timeout is after default
> retrans=3 retransmissions.
>
> I understand the process to be like this;
> call --->0.7 secs --->retransmission--->1.4
> secs--->retransmission--->2.8 secs--->server not responding(major timeout)
>
> However it is pretty clear that this is retrying indefinitely (or at
> least many more times that I would like), as the
> log files show loads of;
> Jul 16 07:56:09 server1 kernel: nfs: server server2 not responding,
> timed out
> Jul 16 07:57:09 server1 last message repeated 4 times
> Jul 16 07:57:09 server1 last message repeated 6 times
>
> and eventually this kills the apache server as all the available
> processes are blocked during "retrying indefinitely", until the apache
> server is restarted. (restarting the nfs server at this point does not
> seem to recover the apache child processes)
>
> So what should my strategy be to stop the failed mount killing apache. I
> care more about the apache staying up, as I don't have that much control
> over the nfs server..
>
> (also I noticed that it seems to timeout quicker with the mount options
> set like (soft, timeo=7, retrans=3) which is unexpected, because they
> are supposed to be the default)

They are the default settings for UDP mounts, but you didn't specify 
UDP.  TCP is the default transport protocol, and has been for some time. 
  TCP uses a long retransmit timeout.  See nfs(5).

-- 
Chuck Lever
