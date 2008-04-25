From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: The text-based mount interface doesn't support -s (--sloppy)
Date: Fri, 25 Apr 2008 10:30:35 -0400
Message-ID: <DF3AF794-BD55-40E8-9696-BC6C40E82713@oracle.com>
References: <20080425081114.GA5148@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21407 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbYDYObm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 10:31:42 -0400
In-Reply-To: <20080425081114.GA5148-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 4:11 AM, Steinar H. Gunderson wrote:
> Hi,
>
> Another user-reported regression. -s used to work, but since 1.1.2  
> it does
> not, probably due to the text-based interface somehow:
>
>  fugl:~> sudo mount.nfs 10.0.0.10:/store /store -s -o rw,asdfasdf
>  mount.nfs: an incorrect mount option was specified


It's not exactly clear what the "sloppy" option is supposed to allow.   
We are trying to figure out right now precisely how this should work.

But before complaining too loudly about text-based mounts, please  
remember that there was no specification for the mount.nfs command and  
mount system call interface except for a 15 year old man page.  We had  
to do something to move forward with IPv6 and RDMA transports; the  
legacy binary-only interface was simply inadequate.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
