Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45875 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002Ab1CBS6w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 13:58:52 -0500
Date: Wed, 2 Mar 2011 13:58:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Ted Ts'o" <tytso@mit.edu>, sfrench@us.ibm.com, agruen@linbit.com,
        dilger.kernel@dilger.ca, sandeen@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V5 00/24]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20110302185847.GA3524@fieldses.org>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20110228211145.GG28617@thunk.org>
 <87oc5vgwqr.fsf@linux.vnet.ibm.com>
 <20110302154943.GB29136@fieldses.org>
 <87ei6pza5v.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87ei6pza5v.fsf@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 02, 2011 at 11:17:56PM +0530, Aneesh Kumar K. V wrote:
> On Wed, 2 Mar 2011 10:49:43 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Tue, Mar 01, 2011 at 12:20:36PM +0530, Aneesh Kumar K. V wrote:
> > > On Mon, 28 Feb 2011 16:11:45 -0500, "Ted Ts'o" <tytso@mit.edu> wrote:
> > > > Hi Aneesh,
> > > > 
> > > > What is the current status of this patch series?  I seem to remember
> > > > that Christoph and Al Viro had some objections; have those been
> > > > cleared yet?  If not, can you summarize what their objections are?
> > > 
> > > The main objection raised was the use of may_delete and may_create inode
> > > operations callback. They are gone now and we have MAY_* flags as
> > > favoured by Al Viro.  The new MAY_* flags added are 
> > > 
> > > #define MAY_CREATE_FILE 128
> > > #define MAY_CREATE_DIR 256
> > > #define MAY_DELETE_CHILD 512
> > > #define MAY_DELETE_SELF 1024
> > > #define MAY_TAKE_OWNERSHIP 2048
> > > #define MAY_CHMOD 4096
> > > #define MAY_SET_TIMES 8192
> > > 
> > > 
> > > > 
> > > > To be honest I haven't been paying super close attention to this patch
> > > > series, and I'm curious what needs to happen with it one way or
> > > > another.
> > > > 
> > > 
> > > IMHO we are ready to get first 11 patches upstream in the next merge
> > > window. ie the below set of patches.
> > 
> > Why aren't all of them ready?
> > 
> 
> All except how to enable richacl in local file system is ready. I
> actually floated two ideas in the patch series
> 
> 1) mount option
> 2) Ext4 compat flags.

The choice of ACL format is a persistant property of the filesystem, not
of a single mount of the filesystem: for example, people can't try out
richacls for one mount and then decide to revert bacak to posix acls.

(Right?)  So I'm assuming we should use the latter--but I don't
understand what ext4 compat flags are.... Is there some disadvantage to
using them?

--b.

> 
> If we can get to decide which one, then the entire set can go in. We also
> want others to review the richacl format. If that cannot be completed by
> next merge window there is no reason to prevent the vfs changes from
> going in. VFS changes are independent of richacl format.
