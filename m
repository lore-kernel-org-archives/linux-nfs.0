Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.bluewatersys.com ([202.124.120.130]:3095 "EHLO
	hayes.bluewaternz.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750739Ab1C1Ei4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 00:38:56 -0400
Message-ID: <4D9010F1.1040909@bluewatersys.com>
Date: Mon, 28 Mar 2011 17:39:13 +1300
From: Ryan Mallon <ryan@bluewatersys.com>
To: Matthew Wilcox <matthew@wil.cx>
CC: viro@zeniv.linux.org.uk, dchinner@redhat.com, Trond.Myklebust@netapp.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 1/2] Add unlocked version of igrab.
References: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com> <1301277361-9453-2-git-send-email-ryan@bluewatersys.com> <20110328025423.GN13806@parisc-linux.org>
In-Reply-To: <20110328025423.GN13806@parisc-linux.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/28/2011 03:54 PM, Matthew Wilcox wrote:
> On Mon, Mar 28, 2011 at 02:56:00PM +1300, Ryan Mallon wrote:
>> Commit 250df6ed274d767da844a5d9f05720b804240197 "fs: protect
>> inode->i_state with inode->i_lock" changes igrab to acquire inode->i_lock,
>> however some callees, notably nfs_inode_add_request, already hold the lock
>> when calling igrab.
> 
> I think a better solution to your problem is to notice that this is
> called in the context of doing a write to an inode.  That means we
> must already have a reference count on this inode, so it can't possibly
> be in I_FREEING or I_WILL_FREE.  That means we can just call __iget()
> instead ... except that __iget isn't exported to modules.

Ah, okay. Thanks for the hint.

A few other locations that I can see that call igrab with inode->i_lock
held are:

  fs/ceph/snap.c::ceph_queue_cap_snap
  fs/ceph/addr.c::ceph_set_page_dirty
  fs/nfs/nfs4state.c::nfs4_get_open_state

There may be some more cases where the locking is less obvious. I don't
know enough about the filesystem code to say whether each of those can
skip the (I_FREEING | I_WILL_FREE) check, or whether the correct
approach is to modify the filesystems themselves so that they do not
hold i_lock when calling igrab (i.e. rework to use a different outer lock)?

If the correct approach is to use __iget or __igrab then I can prepare a
patch for this. In the case of __iget, should it just be marked
EXPORT_SYMBOL and added to include/linux/fs.h?

~Ryan

-- 
Bluewater Systems Ltd - ARM Technology Solution Centre

Ryan Mallon         		5 Amuri Park, 404 Barbadoes St
ryan@bluewatersys.com         	PO Box 13 889, Christchurch 8013
http://www.bluewatersys.com	New Zealand
Phone: +64 3 3779127		Freecall: Australia 1800 148 751
Fax:   +64 3 3779135			  USA 1800 261 2934
