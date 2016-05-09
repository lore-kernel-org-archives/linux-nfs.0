Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214AbcEINA2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 09:00:28 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <31651.1462798652@warthog.procyon.org.uk>
References: <31651.1462798652@warthog.procyon.org.uk> <20160508083543.GA14316@infradead.org> <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 09 May 2016 14:00:25 +0100
Message-ID: <31873.1462798825@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> > > st_gen is
> > > the inode generation number, st_btime is the file creation time, st_version
> > > is the data version number (i_version),
> > 
> > Please define semantics for st_gen and st_version.
> 
> I've been asked to drop st_gen for security reasons.
> 
> I can't offhand think of a way to define st_version (or i_version, for that
> matter) that would be consistent across all filesystems.  I would lean towards
> "gets incremented monotonically by 1 for each data write operation committed,
> but not for any metadata operations", but I'm fairly certain this won't jibe
> with disk operations.

I meant disk filesystems that we have now, not disk operations.

David
