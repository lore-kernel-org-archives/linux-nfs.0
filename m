From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfs: convert proto= option to use netid's rather than
	a protoname
Date: Thu, 29 Oct 2009 00:24:15 -0400
Message-ID: <20091029042415.GA2283@infradead.org>
References: <1256758812-24928-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34723 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbZJ2EYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Oct 2009 00:24:11 -0400
In-Reply-To: <1256758812-24928-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 28, 2009 at 03:40:12PM -0400, Jeff Layton wrote:
> Solaris uses netids as values for the proto= option, so that when
> someone specifies "tcp6" they get traffic over TCP + IPv6. Until
> recently, this has never really been an issue for Linux since it didn't
> support NFS over IPv6.  The netid and the protocol name were generally
> always the same (modulo any strange configuration in /etc/netconfig).
> 
> The solaris manpage documents their proto= option as:
> 
>     proto= _netid_ | rdma

I'm strictly against adding netid braindamage to Linux.  Just because
Solaris made a mistake we don't have to repeat it.

Adding a hack to mount.nfs to parse it is fine, but there's not need to
display it again.
