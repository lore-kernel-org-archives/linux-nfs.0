From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH v2] register NFS_ACL with rpcbind
Date: Tue, 3 Nov 2009 10:13:27 +0100
Message-ID: <200911031013.27247.agruen@suse.de>
References: <4AEF2D19.5090409@redhat.com> <4AEF562B.9070606@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>, Olaf Kirch <okir@suse.de>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:38173 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032AbZKCJL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2009 04:11:29 -0500
In-Reply-To: <4AEF562B.9070606@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 02 November 2009 10:59:07 pm Peter Staubach wrote:
> Hi.
> 
> Here is a patch to modify the NFS server to register the NFS_ACL
> services with the rpcbind daemon.  This allows the client to
> ping for the existence of the NFS_ACL support via commands such
> as "rpcinfo -t <server> nfs_acl".
> 
> This patch also modifies the NFS_ACL support so that responses
> to version 2 NULLPROC requests can be made.
> 
> The changelog for the patch which turned off this functionality
> mentioned something about not registering the NFS_ACL as being
> part of some tradition.  I can't find this tradition and the
> only other implementation which supports NFS_ACL does register
> them with the rpcbind daemon.

I don't understand the reasoning behind .vs_hidden for NFS_ACL, hopefully Olaf 
can clarify. NFS_ACL is the only user of .vs_hidden as far as I can see 
though, so if this is changeg, shouldn't the entire commit bc5fea4 which 
introduced the flag be reverted?

Thanks,
Andreas
