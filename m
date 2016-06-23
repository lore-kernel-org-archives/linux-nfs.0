Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:33481 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751415AbcFWRP5 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jun 2016 13:15:57 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Weston Andros Adamson'" <dros@monkey.org>,
        "'Andreas Gruenbacher'" <andreas.gruenbacher@gmail.com>
Cc: "'Linux Kernel'" <linux-kernel@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>,
        "'linux-nfs list'" <linux-nfs@vger.kernel.org>,
        "'Weston Adamson'" <dros@primarydata.com>
References: <cover.1429868795.git.agruenba@redhat.com> <cover.1429868795.git.agruenba@redhat.com> <39cf890265e2a906a1cf41d6949b5be69903a064.1429868795.git.agruenba@redhat.com> <56F61F7E-9B41-45DD-B478-FE9329DD9983@monkey.org>
In-Reply-To: <56F61F7E-9B41-45DD-B478-FE9329DD9983@monkey.org>
Subject: RE: [RFC v3 42/45] nfs: Add richacl support
Date: Thu, 23 Jun 2016 10:15:31 -0700
Message-ID: <145e01d1cd72$d9b8d570$8d2a8050$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> First, let me say thanks for all the work! We (Primary Data) have been using
> samba with the vfs_richacl module reexporting an nfsv4.2 mount and things
> are working pretty well. You can count on us for testing, bug fixing and code
> review.
> 
> Now for my question: It looks like this call to richacl_apply_masks in the client
> xattr_set path exists so that the knfsd permission check algorithm works
> correctly.
> This makes some pretty big assumptions about the server’s implementation.
> There are other servers out there besides knfsd!
> 
> I think this will have to be fixed before this patch can be accepted. I’m willing
> to help, but I’m wondering where this should be fixed:
> 
> Do we call richacl_apply_masks on the server before setting the xattr so the
> normalized acl is saved, or should we save the ACL as-is and call
> richacl_apply_masks before it’s used?

I definitely want to hear more about this. At some point we will utilize RichACLs in Ganesha.

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

