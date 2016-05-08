Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44874 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbcEHIjW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 May 2016 04:39:22 -0400
Date: Sun, 8 May 2016 01:39:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 5/6] statx: Make windows attributes available for CIFS,
 NTFS and FAT to use
Message-ID: <20160508083921.GB22670@infradead.org>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125813.23636.49830.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160429125813.23636.49830.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 29, 2016 at 01:58:14PM +0100, David Howells wrote:
> Make windows attributes available for CIFS, NTFS and FAT to use in the
> statx struct.  The attribute flags map directly by value to those in the
> CIFS PDU flags.  Some of these bits can also be used by JFS, UFS and HPFS.

Err, no way.  Not that I disagree that some of these might be useful,
but we should define our own set of flags, which would include the
generic part of the IOC_GETFLAGS flags amd whatever we want to add to
them.  And we should probably go for 64-bit flags while we're at it.
