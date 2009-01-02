Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:40430 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbZABTyO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jan 2009 14:54:14 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <ACBF0FE3-9A38-48B3-8E37-3408245AA486@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: =?ISO-8859-1?Q?Elmar_Pr=FC=DFe?= <epruesse@mpi-bremen.de>
In-Reply-To: <495E5768.6050200@mpi-bremen.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed; delsp=yes
Subject: Re: fairness of client?
Date: Fri, 2 Jan 2009 14:53:55 -0500
References: <495E5768.6050200@mpi-bremen.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 2, 2009, at 1:05 PM, Elmar Prüße wrote:
> Hi!
>
> Is there a way to achieve fairness between users _on one client_?
>
> While our users each had their own client, we never had a problem.  
> But since we moved to a terminal server solution with many users  
> sharing one machine, especially large writes cause a significant  
> degradation of responsiveness for everyone else on the same client  
> (ls can take > 1s).

Is it only "ls" that is having this problem?

POSIX requires that stat(2) returns an mtime that reflects the actions  
of the most recent write(2).  Thus, if there are writes to a file  
waiting to go to the server, and someone does a stat(2) on that file,  
the client is required to flush those writes so the server can update  
the file's mtime properly before the stat(2).

Linux likes to cache writes aggressively, so you end up with sometimes  
hundreds of megabytes to flush back before stat(2) can be completed.   
If the writes occur on some other client, the stat'ing client can't  
tell and just does the stat(2) without delay; but the stat(2) results  
don't reflect outstanding writes on other clients.

You can test this scenario by using the "sync" mount option, or  
writing the stat'd file with O_SYNC.  If "ls" becomes fast again, then  
this is your problem.

> Is this a configuration error? Or is the scenario too arcane to have  
> been considered worthwhile optimizing?
>
> We tried moving to NFS4, but that did not improve the situation.
> Would it help to use an auto-mounter to give each user their own  
> mount-point?

Generally NFS mount points share the same mount options and data and  
metadata cache, so this wouldn't address the above problem.

> Or do we need to invest in 10GbE to shift the bottleneck back to the  
> servers disks?
> We run a 2.6.23.11 vanilla kernel. Would a newer version or applying  
> the most recent NFS patches improve the situation?

You might try more recent kernels, as we've tried to improve this  
behavior while not violating the POSIX requirement.

Reducing the amount of data that can be cached before writes are  
flushed automatically is really the only solution.  You can tune the  
kernel to flush sooner with a VM sysctl, but it effects all files on  
the system.

> I would really appreciate any hints as to which of the above is the  
> most promising avenue. I tried finding information regarding this  
> problem, but if there is any out there, it was shadowed by search  
> results concerning a certain car racing game or tutorials for  
> ancient kernel versions.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com