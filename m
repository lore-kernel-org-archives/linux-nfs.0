From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: The text-based mount interface doesn't support -s (--sloppy)
Date: Fri, 25 Apr 2008 10:50:09 -0400
Message-ID: <54BFCFD6-18D0-42E9-ADE9-867BEB1B2AB5@oracle.com>
References: <20080425081114.GA5148@uio.no> <DF3AF794-BD55-40E8-9696-BC6C40E82713@oracle.com> <20080425143543.GA6292@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>,
	Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40365 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbYDYOvb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 10:51:31 -0400
In-Reply-To: <20080425143543.GA6292-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 10:35 AM, Steinar H. Gunderson wrote:
> On Fri, Apr 25, 2008 at 10:30:35AM -0400, Chuck Lever wrote:
>> It's not exactly clear what the "sloppy" option is supposed to allow.
>> We are trying to figure out right now precisely how this should work.
>
> Well, in general it seems to ignore any new options that come into  
> it. The
> problem in question was -o grpid= that was coming in through autofs  
> mounts and was not too easy to remove for the user.

The grpid mount option is what triggered our earlier discussion of -- 
sloppy as well.

An expedient solution may be to tell the kernel mount option parser  
specifically to ignore these common automounter options, like grpid.   
Jeff, what do you think of that?

>> But before complaining too loudly about text-based mounts, please
>> remember that there was no specification for the mount.nfs command  
>> and
>> mount system call interface except for a 15 year old man page.  We  
>> had
>> to do something to move forward with IPv6 and RDMA transports; the
>> legacy binary-only interface was simply inadequate.
>
> Yes, I'm fully aware of that. (In particular, I'm waiting eagerly  
> for IPv6;
> RDMA is a bit out of my range still. :-) ) People seem to depend on  
> a lot of
> options behaving in a specific way, though.

Understood.  Having neither a specification, a unit test suite, nor  
any strong sense of history on the mailing list (ie not having a grip  
on most use cases) means we are shooting blind in this case.

There will be some pain.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
