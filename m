Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43116 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757461Ab1IGXpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Sep 2011 19:45:05 -0400
Date: Wed, 7 Sep 2011 19:44:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jeremy Allison <jra@samba.org>
Subject: Re: [PATCH -V6 00/26]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20110907234408.GA10982@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 05, 2011 at 10:55:22PM +0530, Aneesh Kumar K.V wrote:
> Hi,
> 
> The following set of patches implements VFS and ext4 changes needed to implement
> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> extended by file masks to fit into the standard POSIX file permission model.
> They are designed to work seamlessly locally as well as across the NFSv4 and
> CIFS/SMB2 network file system protocols.

The posix acl mapping that samba and nfsd currently have to do is
painful for everyone and I'm delighted to get away from it.

My main remaining worry (besides the fact that cifs/v4 acls are too
complicated--but what can we do about that?)--is about how exactly the
(acl, mask)->acl mapping is going to work for nfsd and samba.

If we assume that filesystems are going to mostly use acls or mostly
mode bits, then maybe that part doesn't matter a whole lot.  I don't
know.

--b.

> 
> A user-space utility for displaying and changing richacls is available at [4]
> (a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).
> 
> [4] git://git.kernel.org/pub/scm/fs/acl/kvaneesh/richacl.git master
> 
> To test richacl on ext4 use -o richacl mount option. This mount option may later be
> dropped in favour of a feature flag.
> 
> More details regarding richacl can be found at
> http://acl.bestbits.at/richacl/
> 
> Changes from v5:
> a) rebase to v3.1-rc4-131-g9e79e3e
> 
> NOTE: The kernel changes will be pushed to
> git://git.kernel.org/pub/scm/linux/kernel/git/kvaneesh/linux-richacl.git richacl
> when kernel.org is back
> 
> -aneesh
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
