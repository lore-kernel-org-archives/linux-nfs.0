Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754241Ab1JXJRY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Oct 2011 05:17:24 -0400
Date: Mon, 24 Oct 2011 05:17:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V8 00/26]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20111024091716.GA1109@fieldses.org>
References: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> How do we push these changes to Linus tree ? Andrew, Viro, any comment
> on how we can get this merged upstream ?

Andrew, it sounds like you might be willing to shepherd these through?
Let us know what you'd need.

--b.



On Sun, Oct 23, 2011 at 11:13:29PM +0530, Aneesh Kumar K.V wrote:
> Hi,
> 
> The following set of patches implements VFS and ext4 changes needed to implement
> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> extended by file masks to fit into the standard POSIX file permission model.
> They are designed to work seamlessly locally as well as across the NFSv4 and
> CIFS/SMB2 network file system protocols.
> 
> A user-space utility for displaying and changing richacls is available at [4]
> (a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).
> 
> [4] git://github.com/kvaneesh/richacl-tools.git master
> 
> To test richacl on ext4 use tune2fs -O richacl to enable richacl feature and mount
> the file system using -o acl mount option.
> 
> More details regarding richacl can be found at
> http://acl.bestbits.at/richacl/
> 
> Changes from v7:
> a) Update patches based on review comments.
> b) Add acked-by:
> c) Change the richacl xattr format based on review feedback.
> 
> git repository With all the patches can be found at
> git://github.com/kvaneesh/linux.git richacl
> 
> IMHO the patches are ready to be merged upstream.
