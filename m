Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35670 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab1IUTpr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 15:45:47 -0400
Date: Wed, 21 Sep 2011 15:45:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 00/26]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20110921194531.GB23634@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <878vpi73oc.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <878vpi73oc.fsf@skywalker.in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 21, 2011 at 01:00:43PM +0530, Aneesh Kumar K.V wrote:
> On Mon,  5 Sep 2011 22:55:22 +0530, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > Hi,
> > 
> > The following set of patches implements VFS and ext4 changes needed to implement
> > a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> > extended by file masks to fit into the standard POSIX file permission model.
> > They are designed to work seamlessly locally as well as across the NFSv4 and
> > CIFS/SMB2 network file system protocols.
> > 
> > A user-space utility for displaying and changing richacls is available at [4]
> > (a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).
> > 
> > [4] git://git.kernel.org/pub/scm/fs/acl/kvaneesh/richacl.git master
> > 
> > To test richacl on ext4 use -o richacl mount option. This mount option may later be
> > dropped in favour of a feature flag.
> > 
> > More details regarding richacl can be found at
> > http://acl.bestbits.at/richacl/
> > 
> > Changes from v5:
> > a) rebase to v3.1-rc4-131-g9e79e3e
> > 
> > NOTE: The kernel changes will be pushed to
> > git://git.kernel.org/pub/scm/linux/kernel/git/kvaneesh/linux-richacl.git richacl
> > when kernel.org is back
> > 
> 
> I pushed the kernel changes to
> 
> git://github.com/kvaneesh/linux.git richacl

Thanks!  This doesn't seem to have the branch with the followup patches
for nfsd?

--b.

> 
> Userspace code can be found at 
> 
> git://github.com/kvaneesh/richacl-tools.git
> 
> -aneesh
> 
