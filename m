Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54921 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758153Ab1IHKlU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 06:41:20 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jeremy Allison <jra@samba.org>
Subject: Re: [PATCH -V6 00/26]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <20110907234408.GA10982@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110907234408.GA10982@fieldses.org>
Date: Thu, 08 Sep 2011 16:10:59 +0530
Message-ID: <874o0n5nb8.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 7 Sep 2011 19:44:08 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Sep 05, 2011 at 10:55:22PM +0530, Aneesh Kumar K.V wrote:
> > Hi,
> > 
> > The following set of patches implements VFS and ext4 changes needed to implement
> > a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> > extended by file masks to fit into the standard POSIX file permission model.
> > They are designed to work seamlessly locally as well as across the NFSv4 and
> > CIFS/SMB2 network file system protocols.
> 
> The posix acl mapping that samba and nfsd currently have to do is
> painful for everyone and I'm delighted to get away from it.
> 
> My main remaining worry (besides the fact that cifs/v4 acls are too
> complicated--but what can we do about that?)--is about how exactly the
> (acl, mask)->acl mapping is going to work for nfsd and samba.

I already have changes to nfsd that maps NFSv4 ACL to the richacl. You
will find that in richaclv23 branch

git://git.kernel.org/pub/scm/linux/kernel/git/kvaneesh/linux-richacl.git richaclv23

> 
> If we assume that filesystems are going to mostly use acls or mostly
> mode bits, then maybe that part doesn't matter a whole lot.  I don't
> know.
> 

-aneesh
