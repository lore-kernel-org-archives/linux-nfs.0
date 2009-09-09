From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Support "-t nfs,vers=4" mounts in the kernel [take
 4]
Date: Wed, 09 Sep 2009 14:14:43 -0400
Message-ID: <4AA7F093.4030902@RedHat.com>
References: <20090902135032.3550.23170.stgit@matisse.1015granger.net>	 <4AA6A7B5.1060301@RedHat.com> <1252517471.8722.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628AbZIISP1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 14:15:27 -0400
In-Reply-To: <1252517471.8722.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/09/2009 01:31 PM, Trond Myklebust wrote:
> On Tue, 2009-09-08 at 14:51 -0400, Steve Dickson wrote:
>> On 09/02/2009 09:51 AM, Chuck Lever wrote:
>>> Sorry for the repost.  After reading the patch descriptions again, I
>>> thought they needed some clarification.
>>>
>>> ---
>>>
>>> Chuck Lever (4):
>>>       NFS: Allow the "nfs" file system type to support NFSv4
>>>       NFS: Move details of nfs4_get_sb() to a helper
>>>       NFS: Refactor NFSv4 text-based mount option validation
>>>       NFS: Mount option parser should detect missing "port="
>>>
>>>
>>>  fs/nfs/internal.h    |   10 ++
>>>  fs/nfs/super.c       |  202 +++++++++++++++++++++++++++++++++-----------------
>>>  include/linux/nfs4.h |    1 
>>>  3 files changed, 144 insertions(+), 69 deletions(-)
>>>
>> Trond,
>>
>> I'm updating the mount.nfs man pages, and would like give 
>> an guess-ta-mate as to which kernel these patches will be in.
>> Any ideas?
> 
> I'm planning on pushing them out in the upcoming merge window, since the
> patches themselves seem pretty straightforward. I've applied the fixes
> that I suggested, and added the patch to disable vers!=4 in the '-t
> nfs4' case.
> 
> If you'd like to test it all out, I've pushed those patches into the
> nfs-for-2.6.32 branch of my git tree. They should also appear in
> linux-next.
Cool... thanks!

steved.
