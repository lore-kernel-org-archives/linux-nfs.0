Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:48658 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932253AbbJNRlk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 13:41:40 -0400
Subject: Re: [PATCH v5 7/9] vfs: Remove copy_file_range mountpoint checks
To: Christoph Hellwig <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-8-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142347.GD31867@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <561E93C3.2090507@Netapp.com>
Date: Wed, 14 Oct 2015 13:41:23 -0400
MIME-Version: 1.0
In-Reply-To: <20151011142347.GD31867@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/11/2015 10:23 AM, Christoph Hellwig wrote:
> On Wed, Sep 30, 2015 at 01:26:51PM -0400, Anna Schumaker wrote:
>> I still want to do an in-kernel copy even if the files are on different
>> mountpoints, and NFS has a "server to server" copy that expects two
>> files on different mountpoints.  Let's have individual filesystems
>> implement this check instead.
> 
> NAK.  I thing this is a bad idea in general and will only be convinced
> by a properly audited actual implementation.  And even then with a flag
> where the file system specificly needs to opt into this behavior instead
> of getting it by default.
> 

So I should drop this patch even with the pagecache copy?  Andy Adamson will have to add it in later as part of his server-to-server patches.

Anna
