Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49706 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbbHSFCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 01:02:49 -0400
Date: Wed, 19 Aug 2015 06:02:45 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/6 v9] fs: New helper legitimize_mntget() for getting a
 legitimize mnt
Message-ID: <20150819050245.GC18890@ZenIV.linux.org.uk>
References: <55D2DBF6.3010406@gmail.com>
 <55D2DD17.7050504@gmail.com>
 <20150819145650.46352023@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150819145650.46352023@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 19, 2015 at 02:56:50PM +1000, NeilBrown wrote:
> If not, we need to clean up and try again.
> To do this we need to check MNT_SYNC_UMOUNT.
> If that is clear it is safe and best to call mntput() on the mnt.
> If it is set, then we just do the mnt_add_count(mnt, -1) and give up
> completely.

It's more subtle, actually.  See my reply upthread for details, but
basically we rely on rcu_read_lock() held since before that MNT_SYNC_UMOUNT
had been set, making synchronize_rcu() in namespace_unlock() a guaranteed
delay of the final mntput until after we have returned.
