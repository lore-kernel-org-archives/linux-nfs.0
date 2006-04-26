From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 10:19:11 -0400
Message-ID: <444F815F.5050704@RedHat.com>
References: <444EC96B.80400@RedHat.com> <444F72F9.9020402@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: cel@citi.umich.edu
In-Reply-To: <444F72F9.9020402@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Chuck Lever wrote:
> 
> Hi Steve-
> 
> Thanks for digging into this.
> 
> I can't tell, but have you addressed the problem of racing processes 
> generating multiple similar ACCESS requests?  Seems like some kind of 
> serialization through your caching mechanism would resolve that nicely.
No.. I was just trying to duplicate logic that was there...
but that is a good point... It turns out that I messed up the
locking anyways... the NFS_INO_INVALID_ACCESS bit is no longer
being protect by the inode->i_lock which is not good... so I
need to rework that part...


steved.

