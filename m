Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:45672 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab1CDKiY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 05:38:24 -0500
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Ted Ts'o" <tytso@mit.edu>, sfrench@us.ibm.com, agruen@linbit.com,
        dilger.kernel@dilger.ca, sandeen@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V5 00/24]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <20110302185847.GA3524@fieldses.org>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110228211145.GG28617@thunk.org> <87oc5vgwqr.fsf@linux.vnet.ibm.com> <20110302154943.GB29136@fieldses.org> <87ei6pza5v.fsf@linux.vnet.ibm.com> <20110302185847.GA3524@fieldses.org>
Date: Fri, 04 Mar 2011 16:08:15 +0530
Message-ID: <871v2nw4q0.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2 Mar 2011 13:58:47 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Wed, Mar 02, 2011 at 11:17:56PM +0530, Aneesh Kumar K. V wrote:
> > On Wed, 2 Mar 2011 10:49:43 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > On Tue, Mar 01, 2011 at 12:20:36PM +0530, Aneesh Kumar K. V wrote:
> > > > On Mon, 28 Feb 2011 16:11:45 -0500, "Ted Ts'o" <tytso@mit.edu> wrote:
> > > > > Hi Aneesh,
> > > > > 
> > > > > What is the current status of this patch series?  I seem to remember
> > > > > that Christoph and Al Viro had some objections; have those been
> > > > > cleared yet?  If not, can you summarize what their objections are?
> > > > 
> > > > The main objection raised was the use of may_delete and may_create inode
> > > > operations callback. They are gone now and we have MAY_* flags as
> > > > favoured by Al Viro.  The new MAY_* flags added are 
> > > > 
> > > > #define MAY_CREATE_FILE 128
> > > > #define MAY_CREATE_DIR 256
> > > > #define MAY_DELETE_CHILD 512
> > > > #define MAY_DELETE_SELF 1024
> > > > #define MAY_TAKE_OWNERSHIP 2048
> > > > #define MAY_CHMOD 4096
> > > > #define MAY_SET_TIMES 8192
> > > > 
> > > > 
> > > > > 
> > > > > To be honest I haven't been paying super close attention to this patch
> > > > > series, and I'm curious what needs to happen with it one way or
> > > > > another.
> > > > > 
> > > > 
> > > > IMHO we are ready to get first 11 patches upstream in the next merge
> > > > window. ie the below set of patches.
> > > 
> > > Why aren't all of them ready?
> > > 
> > 
> > All except how to enable richacl in local file system is ready. I
> > actually floated two ideas in the patch series
> > 
> > 1) mount option
> > 2) Ext4 compat flags.
> 
> The choice of ACL format is a persistant property of the filesystem, not
> of a single mount of the filesystem: for example, people can't try out
> richacls for one mount and then decide to revert bacak to posix acls.
> 
> (Right?)  So I'm assuming we should use the latter--but I don't
> understand what ext4 compat flags are.... Is there some disadvantage to
> using them?
> 

We already have a mount option to enable posix acl (-o acl|noacl). So
along the same line should we have -o richacl|norichacl or should we
have richacl as a ext4 compat flag EXT4_FEATURE_COMPAT_RICHACL. The
compat feature can be enabled via tune2fs for an already created file
system. Once the compat feature is enabled a -o acl mount option cause
the richacl access check to be enabled. That can also result in
mapping the existing posix acl in the file system to richacl and
using mapped richacl for access restriction. With compat flag once set
we will never be able to mount the file system again to use posix acl
access restriction. (We cannot map richacl to posixacl because richacl
support advanced access masks)


With mount option (-o richacl) we can still mount the file system with
-o acl which implies we will have to ignore the richacl associated with
files and only evaluate the posix acl stored.

-aneesh
