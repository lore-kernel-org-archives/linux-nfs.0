Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54143 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176Ab1IIMsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 08:48:55 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
        akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 00/26] New ACL format for better NFSv4 acl interoperability
Date: Fri, 09 Sep 2011 13:48:18 +0100
Message-ID: <25175.1315572498@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:

> The following set of patches implements VFS and ext4 changes needed to implement
> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> extended by file masks to fit into the standard POSIX file permission model.
> They are designed to work seamlessly locally as well as across the NFSv4 and
> CIFS/SMB2 network file system protocols.
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

Acked-by: David Howells <dhowells@redhat.com> for all patches generally where
I haven't found anything bad.
