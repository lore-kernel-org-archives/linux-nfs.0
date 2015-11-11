Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:60292 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239AbbKKOAV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Nov 2015 09:00:21 -0500
Subject: Re: [PATCH v9 0/4] VFS: In-kernel copy system call
To: Al Viro <viro@ZenIV.linux.org.uk>
References: <1447192413-15376-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20151111033827.GJ22011@ZenIV.linux.org.uk>
CC: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <clm@fb.com>, <darrick.wong@oracle.com>,
        <mtk.manpages@gmail.com>, <andros@netapp.com>, <hch@infradead.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <564349EB.7030900@Netapp.com>
Date: Wed, 11 Nov 2015 09:00:11 -0500
MIME-Version: 1.0
In-Reply-To: <20151111033827.GJ22011@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/10/2015 10:38 PM, Al Viro wrote:
> On Tue, Nov 10, 2015 at 04:53:29PM -0500, Anna Schumaker wrote:
>> Copy system calls came up during Plumbers a while ago, mostly because several
>> filesystems (including NFS and XFS) are currently working on copy acceleration
>> implementations.  We haven't heard from Zach Brown in a while, so I volunteered
>> to push his patches upstream so individual filesystems don't need to keep
>> writing their own ioctls.
> 
> OK, taken for the next cycle.  FWIW, I'm going to toss COMPAT_SYSCALL_DEFINE
> counterpart in as well - right now it's doing only native, AFAICS.
> 

Thanks, Al!
