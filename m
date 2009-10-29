From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfs: convert proto= option to use netid's rather than
	a protoname
Date: Thu, 29 Oct 2009 09:31:31 -0400
Message-ID: <20091029133131.GA19076@infradead.org>
References: <1256758812-24928-1-git-send-email-jlayton@redhat.com> <20091029042415.GA2283@infradead.org> <20091029065816.314f5858@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48527 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbZJ2Nb1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Oct 2009 09:31:27 -0400
In-Reply-To: <20091029065816.314f5858-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 29, 2009 at 06:58:16AM -0400, Jeff Layton wrote:
> There's good reason to keep the userspace utility and kernel in sync
> with respect to options. Otherwise if someone tries to remount a
> filesystem with the options listed in /proc/mounts the result will be
> different, no?

Everything that appear in /proc/self/mounts should also be feedable to
mount.  But we have lots of options that are just for compatiblity and
are parsed by mount but turned into something else for /proc/self/mounts
display.

