Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949Ab0G0Nld (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jul 2010 09:41:33 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <8426.1279548573@redhat.com>
References: <8426.1279548573@redhat.com> <20100718084955.GB27794@infradead.org> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021720.5544.19973.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, Christoph Hellwig <hch@infradead.org>,
        viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 09/18] xstat: Make special system filesystems return FS_SPECIAL_FL [ver #6]
Date: Tue, 27 Jul 2010 14:41:24 +0100
Message-ID: <17717.1280238084@redhat.com>
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

David Howells <dhowells@redhat.com> wrote:

> Also, not all the flags are per-filesystem.  The following are:
> 
> 	FS_SPECIAL_FL		/* Special file as found in procfs/sysfs */
> 	FS_REMOTE_FL		/* File is remote */

Actually, that last is not true; FS_REMOTE_FL is per-file, not per-fs.  You
can have a filesystem that has fabricated files and remote files.  For
instance, with kAFS at some point you will be go into /afs, do a lookup for a
directory that doesn't exist, but whose name represents a cell+volume, the
filesystem will fabricate a local directory and then attempt to mount a remote
directory on to it.

David
