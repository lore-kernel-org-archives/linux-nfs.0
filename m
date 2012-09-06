Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:38794 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab2IFCyL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2012 22:54:11 -0400
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <yan@linux.vnet.ibm.com>;
	Thu, 6 Sep 2012 08:24:08 +0530
Date: Thu, 6 Sep 2012 10:53:58 +0800
From: Guo Chao <yan@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: Re: [RFC PATCH 02/13] vfs: pull ext4's double-i_mutex-locking into
 common code
Message-ID: <20120906025358.GA6679@yanx>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1346878524-10585-3-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 05, 2012 at 04:55:12PM -0400, J. Bruce Fields wrote:
> +/**
> + * lock_two_nondirectories - release locks from lock_two_nondirectories()
    unlock_two_nondirectories

> + * @inode1: first inode to unlock
> + * @inode2: second inode to lock
                             unlock

