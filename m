Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:60546 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529Ab1CAGvJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2011 01:51:09 -0500
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: "Ted Ts'o" <tytso@mit.edu>
Cc: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, bfields@fieldses.org, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V5 00/24]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <20110228211145.GG28617@thunk.org>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110228211145.GG28617@thunk.org>
Date: Tue, 01 Mar 2011 12:20:36 +0530
Message-ID: <87oc5vgwqr.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 28 Feb 2011 16:11:45 -0500, "Ted Ts'o" <tytso@mit.edu> wrote:
> Hi Aneesh,
> 
> What is the current status of this patch series?  I seem to remember
> that Christoph and Al Viro had some objections; have those been
> cleared yet?  If not, can you summarize what their objections are?

The main objection raised was the use of may_delete and may_create inode
operations callback. They are gone now and we have MAY_* flags as
favoured by Al Viro.  The new MAY_* flags added are 

#define MAY_CREATE_FILE 128
#define MAY_CREATE_DIR 256
#define MAY_DELETE_CHILD 512
#define MAY_DELETE_SELF 1024
#define MAY_TAKE_OWNERSHIP 2048
#define MAY_CHMOD 4096
#define MAY_SET_TIMES 8192


> 
> To be honest I haven't been paying super close attention to this patch
> series, and I'm curious what needs to happen with it one way or
> another.
> 

IMHO we are ready to get first 11 patches upstream in the next merge
window. ie the below set of patches.

vfs: Make acl_permission_check() work for richacls
vfs: Add permission flags for setting file attributes
vfs: Make the inode passed to inode_change_ok non-const
vfs: Add delete child and delete self permission flags
vfs: Add new file and directory create permission flags
vfs: Optimize out IS_RICHACL() if CONFIG_FS_RICHACL is not defined
vfs: Add IS_RICHACL() test for richacl support
vfs: Add generic IS_ACL() test for acl support
vfs: Add a comment to inode_permission()
vfs: Pass all mask flags down to iop->check_acl
vfs: Indicate that the permission functions take all the MAY_* flags

-aneesh
