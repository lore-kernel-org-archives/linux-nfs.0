Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:57628 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbaD0QPM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:15:12 -0400
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:15:10 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 00/22]  New ACL format for better NFSv4 acl interoperability
Date: Sun, 27 Apr 2014 21:44:31 +0530
Message-Id: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

As per LSF/MM summit discussion I am reposting the richacl patchset for
upstream inclusion. The patchset includes minimal changes required to implement
a new acl model similar to NFSv4 ACL. The acl model selection is based on
file system feature flag. 

The following set of patches implements VFS and ext4 changes needed to implement
a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
extended by file masks to fit into the standard POSIX file permission model.
They are designed to work seamlessly locally as well as across the NFSv4 and
CIFS/SMB2 network file system protocols.

A user-space utility for displaying and changing richacls is available at [1]
(a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).

[1] git://github.com/kvaneesh/richacl-tools.git master

To test richacl on ext4, create the file sytem with richacl feature flag
(mkfs.ext4 -O richacl or  tune2fs -O richacl). With richacl feature enabled
using mount option "acl" will switch to using richacl instead of posixacl.

More details regarding richacl can be found at
http://acl.bestbits.at/richacl/

Previous posting of the patchset can be found at:
http://mid.gmane.org/1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
"[PATCH -V8 00/26]  New ACL format for better NFSv4 acl interoperability"

The complete patchset can also be found at:
https://github.com/kvaneesh/linux/commits/richacl-for-upstream

Since we are trying to get the changes merged upstream after a long time, I am
posting this as V1 again. I Also dropped the Acked-by tag from
David Howells <dhowells@redhat.com> and J. Bruce Fields <bfields@redhat.com>.
Please let me know if I can add them back again.

-aneesh

