From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: The text-based mount interface doesn't support -s (--sloppy)
Date: Fri, 25 Apr 2008 16:35:43 +0200
Message-ID: <20080425143543.GA6292@uio.no>
References: <20080425081114.GA5148@uio.no> <DF3AF794-BD55-40E8-9696-BC6C40E82713@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:48538 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbYDYOfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 10:35:46 -0400
In-Reply-To: <DF3AF794-BD55-40E8-9696-BC6C40E82713@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2008 at 10:30:35AM -0400, Chuck Lever wrote:
> It's not exactly clear what the "sloppy" option is supposed to allow.   
> We are trying to figure out right now precisely how this should work.

Well, in general it seems to ignore any new options that come into it. The
problem in question was -o grpid= that was coming in through autofs mounts
and was not too easy to remove for the user.

> But before complaining too loudly about text-based mounts, please  
> remember that there was no specification for the mount.nfs command and  
> mount system call interface except for a 15 year old man page.  We had  
> to do something to move forward with IPv6 and RDMA transports; the  
> legacy binary-only interface was simply inadequate.

Yes, I'm fully aware of that. (In particular, I'm waiting eagerly for IPv6;
RDMA is a bit out of my range still. :-) ) People seem to depend on a lot of
options behaving in a specific way, though.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
