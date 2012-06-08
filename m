Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41348 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729Ab2FHNhC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 09:37:02 -0400
Message-ID: <4FD1FFFD.3020301@netapp.com>
Date: Fri, 08 Jun 2012 09:37:01 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect mount
 option
References: <20120607150456.GO12795@8bytes.org> <4FD0C4C2.8020605@netapp.com> <20120607155006.GR12795@8bytes.org> <4FD0CEB0.9040804@netapp.com> <20120608130352.GU12795@8bytes.org> <4FD1FC02.2000608@netapp.com> <20120608133317.GW12795@8bytes.org>
In-Reply-To: <20120608133317.GW12795@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2012 09:33 AM, Joerg Roedel wrote:
> On Fri, Jun 08, 2012 at 09:20:02AM -0400, Bryan Schumaker wrote:
>> On 06/08/2012 09:03 AM, Joerg Roedel wrote:
>>> On Thu, Jun 07, 2012 at 11:54:24AM -0400, Bryan Schumaker wrote:
>>>> On 06/07/2012 11:50 AM, Joerg Roedel wrote:
>>>>> mount -o nfsvers=3 ...
>>>>
>>>> What about `mount -o vers=4 ...`?  I'm compiling a kernel right now to
>>>> see if I can reproduce this, what NFS .config options do you have set?
>>>> (`cat .config | grep CONFIG_NFS_` should be good enough).
>>>
>>> Okay, I tracked it down somewhat. The problem is that the nfs-version
>>> is not set in my case so that data->version in nfs_init_server is 0. The
>>> function returns -EPROTONOSUPPORT in this case which causes the mount
>>> to fail. The evil commit is db8333519 and reverting it fixes the issue
>>> for me. Patch attached.
>>
>> Thanks!  I wasn't able to reproduce this on Ubuntu 12.04, so now I'm
>> setting up 10.04 to see if that makes a difference.  I'd like to
>> understand what's going on (and why my other patch didn't fix this
>> problem) before reverting.
> 
> Your other patch only touched the nfs4 path, but in my setup nfs3 was in
> use. Therefore the patch didn't help. I just figured out that
> nfs_fs_mount is shared between nfs23 and nfs4, so the first patch
> probably breaks nfs4. I send another one which takes this into account.

Would something like this work? (I haven't tried it yet).  Setting it in nfs_alloc_parsed_mount_data() might work too...

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index bdd6731..906f09c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1867,6 +1867,7 @@ static int nfs23_validate_mount_data(void *options,
        if (data == NULL)
                goto out_no_data;
 
+       args->version = NFS_DEFAULT_VERSION;
        switch (data->version) {
        case 1:
                data->namlen = 0;
--


> 
> Regards,
> 
> 	Joerg
> 
> 


