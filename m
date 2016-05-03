Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756456AbcECUYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2016 16:24:42 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <ABA29DAB-BDD2-44E9-8E2B-AE227A823ECD@dilger.ca>
References: <ABA29DAB-BDD2-44E9-8E2B-AE227A823ECD@dilger.ca> <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125759.23636.10635.stgit@warthog.procyon.org.uk>
To: Andreas Dilger <adilger@dilger.ca>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 3/6] statx: Ext4: Return enhanced file attributes
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 03 May 2016 21:24:40 +0100
Message-ID: <10499.1462307080@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andreas Dilger <adilger@dilger.ca> wrote:

> > (3) FS_xxx_FL flags are returned as for ioctl(FS_IOC_GETFLAGS), setting
> >     STATX_IOC_FLAGS.
> 
> I don't see where this is implemented in this patch, and it should be
> removed from the commit message to avoid confusion.

Oops - I forgot to remove it from the other patches.

David
