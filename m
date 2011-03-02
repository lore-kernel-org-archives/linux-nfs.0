Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:43466 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756375Ab1CBRsI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Mar 2011 12:48:08 -0500
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Ted Ts'o" <tytso@mit.edu>, sfrench@us.ibm.com, agruen@linbit.com,
        dilger.kernel@dilger.ca, sandeen@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V5 00/24]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <20110302154943.GB29136@fieldses.org>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110228211145.GG28617@thunk.org> <87oc5vgwqr.fsf@linux.vnet.ibm.com> <20110302154943.GB29136@fieldses.org>
Date: Wed, 02 Mar 2011 23:17:56 +0530
Message-ID: <87ei6pza5v.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2 Mar 2011 10:49:43 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Tue, Mar 01, 2011 at 12:20:36PM +0530, Aneesh Kumar K. V wrote:
> > On Mon, 28 Feb 2011 16:11:45 -0500, "Ted Ts'o" <tytso@mit.edu> wrote:
> > > Hi Aneesh,
> > > 
> > > What is the current status of this patch series?  I seem to remember
> > > that Christoph and Al Viro had some objections; have those been
> > > cleared yet?  If not, can you summarize what their objections are?
> > 
> > The main objection raised was the use of may_delete and may_create inode
> > operations callback. They are gone now and we have MAY_* flags as
> > favoured by Al Viro.  The new MAY_* flags added are 
> > 
> > #define MAY_CREATE_FILE 128
> > #define MAY_CREATE_DIR 256
> > #define MAY_DELETE_CHILD 512
> > #define MAY_DELETE_SELF 1024
> > #define MAY_TAKE_OWNERSHIP 2048
> > #define MAY_CHMOD 4096
> > #define MAY_SET_TIMES 8192
> > 
> > 
> > > 
> > > To be honest I haven't been paying super close attention to this patch
> > > series, and I'm curious what needs to happen with it one way or
> > > another.
> > > 
> > 
> > IMHO we are ready to get first 11 patches upstream in the next merge
> > window. ie the below set of patches.
> 
> Why aren't all of them ready?
> 

All except how to enable richacl in local file system is ready. I
actually floated two ideas in the patch series

1) mount option
2) Ext4 compat flags.

If we can get to decide which one, then the entire set can go in. We also
want others to review the richacl format. If that cannot be completed by
next merge window there is no reason to prevent the vfs changes from
going in. VFS changes are independent of richacl format.

-aneesh
