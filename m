Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:26186 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757032AbaCEUyc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 15:54:32 -0500
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <338027154-1394050544-cardhu_decombobulator_blackberry.rim.net-1945813324-@b5.c4.bise6.blackberry>
Date: Wed, 5 Mar 2014 15:54:18 -0500
Cc: Andrew Martin <amartin@xes-inc.com>, linux-nfs-owner@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <227F2748-4312-43D5-A0C4-4CE2F1E593DD@oracle.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <338027154-1394050544-cardhu_decombobulator_blackberry.rim.net-1945813324-@b5.c4.bise6.blackberry>
To: bhawley@luminex.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 5, 2014, at 3:15 PM, Brian Hawley <bhawley@luminex.com> wrote:

> 
> In my experience, you won't get the i/o errors reported back to the read/write/close operations.   I don't know for certain, but I suspect this may be due to caching and chunking to turn I/o matching the rsize/wsize settings; and possibly the fact that the peer disconnection isn't noticed unless the nfs server resets (ie cable disconnection isn't sufficient).
> 
> The inability to get the i/o errors back to the application has been a major pain for us.
> 
> On a lark we did find that repeated unmont -f's does get i/o errors back to the application, but isn't our preferred way.
> 
> 
> -----Original Message-----
> From: Andrew Martin <amartin@xes-inc.com>
> Sender: linux-nfs-owner@vger.kernel.org
> Date: 	Wed, 5 Mar 2014 11:45:24 
> To: <linux-nfs@vger.kernel.org>
> Subject: Optimal NFS mount options to safely allow interrupts and timeouts
> on newer kernels
> 
> Hello,
> 
> Is it safe to use the "soft" mount option with proto=tcp on newer kernels (e.g
> 3.2 and newer)? Currently using the "defaults" nfs mount options on Ubuntu
> 12.04 results in processes blocking forever in uninterruptable sleep if they
> attempt to access a mountpoint while the NFS server is offline. I would prefer
> that NFS simply return an error to the clients after retrying a few times, 
> however I also cannot have data loss. From the man page, I think these options
> will give that effect?
> soft,proto=tcp,timeo=10,retrans=3
> 
>> From my understanding, this will cause NFS to retry the connection 3 times (once
> per second), and then if all 3 are unsuccessful return an error to the
> application. Is this correct? Is there a risk of data loss or corruption by
> using "soft" in this way? Or is there a better way to approach this?

There is always a silent data corruption risk with “soft.” Using TCP and a long retransmit timeout mitigates the risk, but it is still there. A one second timeout for TCP is very short, and will almost certainly result in trouble, especially if the server or network are slow.

You should be able to ^C any waiting NFS process. Blocking forever is usually the sign of a bug.

In general, NFS is not especially tolerant of server unavailability. You may want to consider some other distributed file system protocol that is more fault-tolerant, or find ways to ensure your NFS servers are always accessible.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



