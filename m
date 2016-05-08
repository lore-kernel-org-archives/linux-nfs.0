Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44870 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbcEHIiI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 May 2016 04:38:08 -0400
Date: Sun, 8 May 2016 01:38:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 3/6] statx: Ext4: Return enhanced file attributes
Message-ID: <20160508083807.GA22670@infradead.org>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125759.23636.10635.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160429125759.23636.10635.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 29, 2016 at 01:57:59PM +0100, David Howells wrote:
>  (3) FS_xxx_FL flags are returned as for ioctl(FS_IOC_GETFLAGS), setting
>      STATX_IOC_FLAGS.

Doesn't look like it is.  Which actually is a good thing given how much
of a mess FS_IOC_GETFLAGS is.
