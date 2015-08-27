Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36719 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbH0XCx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 19:02:53 -0400
Subject: Re: [PATCH 4/6 v9] fs: New helper legitimize_mntget() for getting a
 legitimize mnt
To: Al Viro <viro@ZenIV.linux.org.uk>, NeilBrown <neilb@suse.com>
References: <55D2DBF6.3010406@gmail.com> <55D2DD17.7050504@gmail.com>
 <20150819145650.46352023@noble> <20150819050245.GC18890@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55DF970F.6080308@gmail.com>
Date: Fri, 28 Aug 2015 07:02:39 +0800
MIME-Version: 1.0
In-Reply-To: <20150819050245.GC18890@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/19/2015 13:02, Al Viro wrote:
> On Wed, Aug 19, 2015 at 02:56:50PM +1000, NeilBrown wrote:
>> If not, we need to clean up and try again.
>> To do this we need to check MNT_SYNC_UMOUNT.
>> If that is clear it is safe and best to call mntput() on the mnt.
>> If it is set, then we just do the mnt_add_count(mnt, -1) and give up
>> completely.
> 
> It's more subtle, actually.  See my reply upthread for details, but
> basically we rely on rcu_read_lock() held since before that MNT_SYNC_UMOUNT
> had been set, making synchronize_rcu() in namespace_unlock() a guaranteed
> delay of the final mntput until after we have returned.
> 

Thanks for the comments.
I will update this patch according to Neil's comments and __legitimize_mnt.

thanks,
Kinglong Mee
