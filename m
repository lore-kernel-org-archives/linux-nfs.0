Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:8556 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473AbcHHPGY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2016 11:06:24 -0400
Subject: Re: [PATCH v2 0/3] Client reconnection fixes
To: Trond Myklebust <trondmy@primarydata.com>
References: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
 <963f74cb-9e46-72c8-5168-840021dc0453@Netapp.com>
 <26FE1038-A417-464E-AA40-882FD96ACEE7@primarydata.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <f88bd344-decb-8a16-3d7c-1adb543a9d58@Netapp.com>
Date: Mon, 8 Aug 2016 11:06:21 -0400
MIME-Version: 1.0
In-Reply-To: <26FE1038-A417-464E-AA40-882FD96ACEE7@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying these three directly on 4.8-rc1 gave me problems.  Looks like I'm missing xs_reconnect_delay() in my git tree which was added by "SUNRPC: Fix reconnection timeouts" in v1 of your patches (but missing in this series).

Anna

On 08/08/2016 10:58 AM, Trond Myklebust wrote:
> There are no particular dependencies beyond 4.8-rc1 that I’m aware of. I have applied them to my linux-next branch:
> 
>  http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/linux-next
> 
> 
>> On Aug 8, 2016, at 10:26, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>
>> Hi Trond,
>>
>> Do these patches depend on another patch set?  I tried applying the first patch, but my git tree is missing sha1 information for net/sunrpc/xprtsock.c.
>>
>> Thanks,
>> Anna
>>
>> On 08/05/2016 07:37 PM, Trond Myklebust wrote:
>>> v1: Cap the backoff timer to the max RPC message timeout
>>> v2: Add a cap at 1/2 NFSv4 lease period to ensure we don't miss lease renewal
>>>
>>> Trond Myklebust (3):
>>>  SUNRPC: Limit the reconnect backoff timer to the max RPC message
>>>    timeout
>>>  NFSv4: Cleanup the setting of the nfs4 lease period
>>>  NFSv4: Cap the transport reconnection timer at 1/2 lease period
>>>
>>> fs/nfs/nfs4_fs.h            |  4 ++++
>>> fs/nfs/nfs4proc.c           |  9 +++------
>>> fs/nfs/nfs4renewd.c         | 20 ++++++++++++++++++++
>>> fs/nfs/nfs4state.c          |  9 +++------
>>> include/linux/sunrpc/clnt.h |  2 ++
>>> include/linux/sunrpc/xprt.h |  3 ++-
>>> net/sunrpc/clnt.c           | 24 ++++++++++++++++++++++++
>>> net/sunrpc/xprtsock.c       | 18 ++++++++++++------
>>> 8 files changed, 70 insertions(+), 19 deletions(-)
>>>
>>
> 

