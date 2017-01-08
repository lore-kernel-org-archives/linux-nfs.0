Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33100 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751310AbdAHMnp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2017 07:43:45 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so22734022pfg.0
        for <linux-nfs@vger.kernel.org>; Sun, 08 Jan 2017 04:43:45 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH] NFSD: only support readonly export for !fsync and
 readonly filesystem
To: Christoph Hellwig <hch@infradead.org>
References: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
 <20170108100715.GC25268@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Steve Dickson <SteveD@redhat.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <2e84e208-11b5-6de0-e222-2eb992b61b8f@gmail.com>
Date: Sun, 8 Jan 2017 20:43:34 +0800
MIME-Version: 1.0
In-Reply-To: <20170108100715.GC25268@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/8/2017 18:07, Christoph Hellwig wrote:
> On Sat, Dec 31, 2016 at 09:18:08PM +0800, Kinglong Mee wrote:
>> Commit fae5096ad217
>> "nfsd: assume writeable exportabled filesystems have f_sync"
>> have remove the checking of f_sync.
>>
>> Christoph Hellwig suggests,
>> "Warn and refuse the writable export."
>>
>> I think just covert to a readonly export for !fsync filesystem,
>> also, for a readonly filesystem is reasonable.
> 
> I don't like degrading the export.  We should require an explicit
> ro option in this case.

With this patch, we can see the ro option in the proc file.

# mount |grep xfs
/dev/sdc on /nfs type xfs (ro,relatime,seclabel,attr2,inode64,noquota)

# cat /etc/exports
/nfs/	*(rw,no_subtree_check,no_root_squash,insecure,fsid=0)

# cat /proc/fs/nfsd/exports 
# Version 1.1
# Path Client(Flags) # IPs
/nfs	*(ro,insecure,no_root_squash,sync,wdelay,no_subtree_check,fsid=0,uuid=a4a352bc:252a47cb:b3953193:040e050d,sec=1,rw,insecure,no_root_squash)

thanks,
Kinglong Mee
