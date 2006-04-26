From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: [NFS] [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 09:17:45 -0400
Message-ID: <444F72F9.9020402@citi.umich.edu>
References: <444EC96B.80400@RedHat.com>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <444EC96B.80400@RedHat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Steve Dickson wrote:
> Currently the NFS client caches ACCESS information on a per uid basis
> which fall apart when different process with different uid consistently
> access the same directory. The end result being a storm of needless
> ACCESS calls...
> 
> The attached patch used a hash table to store the nfs_access_entry
> entires which cause the ACCESS request to only happen when the
> attributes timeout.. The table is indexed by the addition of the
> nfs_inode pointer and the cr_uid in the cred structure which should
> spread things out nicely for some decent scalability (although the
> locking scheme may need to be reworked a bit). The table has 256 entries
> of struct list_head giving it a total size of 2k.
> 
> The patch is based on Trond's GIT tree...
> 
> Comments?
> 
> steved.

Hi Steve-

Thanks for digging into this.

I can't tell, but have you addressed the problem of racing processes 
generating multiple similar ACCESS requests?  Seems like some kind of 
serialization through your caching mechanism would resolve that nicely.

-- 
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>
