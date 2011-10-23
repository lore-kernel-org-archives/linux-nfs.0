Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:41667 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab1JWRoT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Oct 2011 13:44:19 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V8 00/26]  New ACL format for better NFSv4 acl interoperability
Date: Sun, 23 Oct 2011 23:13:29 +0530
Message-Id: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

The following set of patches implements VFS and ext4 changes needed to implement
a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
extended by file masks to fit into the standard POSIX file permission model.
They are designed to work seamlessly locally as well as across the NFSv4 and
CIFS/SMB2 network file system protocols.

A user-space utility for displaying and changing richacls is available at [4]
(a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).

[4] git://github.com/kvaneesh/richacl-tools.git master

To test richacl on ext4 use tune2fs -O richacl to enable richacl feature and mount
the file system using -o acl mount option.

More details regarding richacl can be found at
http://acl.bestbits.at/richacl/

Changes from v7:
a) Update patches based on review comments.
b) Add acked-by:
c) Change the richacl xattr format based on review feedback.

git repository With all the patches can be found at
git://github.com/kvaneesh/linux.git richacl

IMHO the patches are ready to be merged upstream. How do we push these changes
to Linus tree ? Andrew, Viro, any comment on how we can get this merged upstream ?

-aneesh
In-Reply-To: 

