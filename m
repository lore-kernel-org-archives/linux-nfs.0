From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: "sync" mount option semantics
Date: Wed, 5 Mar 2008 15:14:45 -0500
Message-ID: <7F29C156-5FD4-433A-A859-4DFC284FF29D@oracle.com>
References: <9DC7FC7A-41B0-43C6-9759-8DF253C47EEE@oracle.com> <1204740788.3356.9.camel@heimdal.trondhjem.org> <7915C1E7-A21C-4A6A-90CD-8E63E68FD780@oracle.com> <1204746254.5035.22.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:45881 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbYCEUPH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2008 15:15:07 -0500
In-Reply-To: <1204746254.5035.22.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 5, 2008, at 2:44 PM, Trond Myklebust wrote:
> On Wed, 2008-03-05 at 14:25 -0500, Chuck Lever wrote:
>> On Mar 5, 2008, at 1:13 PM, Trond Myklebust wrote:
>>> On Tue, 2008-03-04 at 18:15 -0500, Chuck Lever wrote:
>>>> Hi Trond-
>>>>
>>>> I have kind of an academic question.
>>>>
>>>> When an NFS file system is mounted with the "sync" option, only
>>>> writes via sys_write appear to be affected.  Writes via mmap or  
>>>> pages
>>>> dirtied via a loopback device are not affected at all.
>>>>
>>>> Similarly, O_SYNC only appears to affect sys_write and not mmap or
>>>> loopback.
>>>>
>>>> Is this the desired behavior?  If so, why not include cached  
>>>> writes?
>>>> Should we document this in nfs(5)?
>>>
>>> What does it mean to have "synchronous writes with mmap"? I'm not  
>>> sure
>>> that I really understand your concern: mmap is by its very nature
>>> asynchronous. AFAIK, the only guarantee you have w.r.t.
>>> synchronicity is
>>> that msync(MS_SYNC) can only complete once the data is on disk.
>>
>> Well, one way these are different is that the client still generates
>> multi-page UNSTABLE writes for mmap files when the "sync" option is
>> in effect, while for files written via write(2) the request is broken
>> into a sequence of single page NFS writes on the wire.
>
> Nope, I can't see that this is the case. Where do we enforce stable
> writes for the sync mount option?
>
> AFAIK, the writeout in the O_SYNC/IS_SYNC case is enforced using
> nfs_do_fsync(), which again calls nfs_wb_all() in the usual manner.
> There is nothing there that enforces stable writes...

OK, that looks like it changed in 2.6.20.  I'm looking at older kernels.

Thanks for clarifying.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
