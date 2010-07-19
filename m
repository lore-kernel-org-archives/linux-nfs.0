Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933591Ab0GSOJk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 10:09:40 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100718084955.GB27794@infradead.org>
References: <20100718084955.GB27794@infradead.org> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021720.5544.19973.stgit@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 09/18] xstat: Make special system filesystems return FS_SPECIAL_FL [ver #6]
Date: Mon, 19 Jul 2010 15:09:33 +0100
Message-ID: <8426.1279548573@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Christoph Hellwig <hch@infradead.org> wrote:

> special is not a very useful identifier.  Also what you are returning
> is per-filesystem data, not per-file.  This needs to go into statfs,
> not into stat.  We're about to introduce flags for statfs, so try
> to do it ontop of those.
> 
> The same thing applies to the remote flag in the next patch.

Which means that you have to do two calls (xstat+statfs) to find this
information that we can return pretty much for free here, though you can cache
it based on st_dev, I suppose.

Also, not all the flags are per-filesystem.  The following are:

	FS_SPECIAL_FL		/* Special file as found in procfs/sysfs */
	FS_REMOTE_FL		/* File is remote */

but the rest aren't:

	FS_AUTOMOUNT_FL		/* Specific automount point */
	FS_AUTOMOUNT_ANY_FL	/* Unspecific automount directory */
	FS_ENCRYPTED_FL		/* File is encrypted */
	FS_HIDDEN_FL		/* File is marked hidden (DOS+) */
	FS_SYSTEM_FL		/* File is marked system (DOS+) */
	FS_ARCHIVE_FL		/* File is marked archive (DOS+) */
	FS_TEMPORARY_FL		/* File is temporary (NTFS/CIFS) */
	FS_OFFLINE_FL		/* File is offline (CIFS) */
	FS_REPARSE_POINT_FL	/* Reparse point (NTFS/CIFS) */

David
