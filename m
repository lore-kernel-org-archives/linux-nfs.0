Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757065Ab2EORxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 13:53:41 -0400
Date: Tue, 15 May 2012 13:53:08 -0400
From: Josef Bacik <josef@redhat.com>
To: Josef Bacik <josef@redhat.com>
Cc: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, adilger@dilger.ca, tytso@mit.edu, jack@suse.cz
Subject: Re: [PATCH] ext4: fix how i_version is modified and turn it on by
 default V2
Message-ID: <20120515175308.GB1907@localhost.localdomain>
References: <1337092396-3272-1-git-send-email-josef@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337092396-3272-1-git-send-email-josef@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 10:33:16AM -0400, Josef Bacik wrote:
> This makes MS_I_VERSION be turned on by default.  Ext4 had been
> unconditionally doing i_version++ in a few cases anway so the mount option
> was kind of silly.  This patch also removes the update in mark_inode_dirty
> and makes all of the cases where we update ctime also do inode_inc_iversion.
> file_update_time takes care of the write case and all the places where we
> update iversion are protected by the i_mutex so there should be no extra
> i_lock overhead in the normal non-exported fs case.  Thanks,
> 

Ok did some basic benchmarking with dd, I ran

dd if=/dev/zero of=/mnt/btrfs-test/file bs=1 count=10485760
dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=1000
dd if=/dev/zero of=/mnt/btrfs-test/file bs=1M count=5000

3 times with the patch and without the patch.  With the worst case scenario
there is about a 40% longer run time, going from on average 12 seconds to 17
seconds.  With the other two runs they are the same runtime with the 1 megabyte
blocks.  So the question is, do we care about this worst case since any sane
application developer isn't going to do writes that small?  Thanks,

Josef
