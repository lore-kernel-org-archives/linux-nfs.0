From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Thu, 11 Sep 2008 12:55:47 -0400
Message-ID: <8BFB4AE0-3EF1-41FA-A13B-27E380A79950@oracle.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com> <20080908190212.GF28123@merfinllc.com> <76bd70e30809081415h6b55a8dfl8171634c576ac946@mail.gmail.com> <20080909194644.GI5290@merfinllc.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12316 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbYIKQ4H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2008 12:56:07 -0400
In-Reply-To: <20080909194644.GI5290-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 9, 2008, at Sep 9, 2008, 3:46 PM, Aaron Straus wrote:
> Hi,
>
> On Sep 08 05:15 PM, Chuck Lever wrote:
>> I think I saw some recent work in Trond's development branch that
>> makes some changes in this area.  I will wait for him to respond to
>> this thread.
>
> One other piece of information.
>
> Of the bisected offending commit:
>
> commit e261f51f25b98c213e0b3d7f2109b117d714f69d
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Dec 5 00:35:41 2006 -0500
>
>    NFS: Make nfs_updatepage() mark the page as dirty.
>
>    This will ensure that we can call set_page_writeback() from within
>    nfs_writepage(), which is always called with the page lock set.
>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>
>
> It seems to be this hunk which introduces the problem:
>
>
> @@ -628,7 +667,6 @@ static struct nfs_page *  
> nfs_update_request(struct nfs_open_context* ctx,
> 				return ERR_PTR(error);
> 			}
> 			spin_unlock(&nfsi->req_lock);
> -			nfs_mark_request_dirty(new);
> 			return new;
> 		}
> 		spin_unlock(&nfsi->req_lock);
>
>
>
> If I add that function call back in... the problem disappears.  I  
> don't
> know if this just papers over the real problem though?

It's possible that the NFS write path as it exists after this commit  
is not marking certain pages dirty at the same time as others.  An  
asynchronous flush call from the VM would catch some of the dirty  
pages, then later, others, resulting in the pages flushing to the  
server out of order.

However, I poked around a little bit in late model kernels yesterday  
and found that the changes from Trond I referred to earlier are  
already in 2.6.27.  These rework this area significantly, so reverting  
this hunk alone will be more difficult in recent kernels.

In addition I notice that one purpose of this commit is to change the  
page locking scheme in the NFS client's write path.  I wouldn't advise  
simply adding this nfs_mark_request_dirty() call back in.  It could  
result in deadlocks for certain workloads (perhaps not your specific  
workload, though).

A more thorough review of the NFS write and flush logic that exists in  
2.6.27 is needed if we choose to recognize this issue as a real problem.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
