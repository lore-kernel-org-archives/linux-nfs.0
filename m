Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755552Ab2GKTB0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jul 2012 15:01:26 -0400
Date: Wed, 11 Jul 2012 15:00:39 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        michael.brantley@deshaw.com, hch@infradead.org, miklos@szeredi.hu,
        pstaubach@exagrid.com
Subject: Re: [PATCH v3 00/17] vfs: add the ability to retry on ESTALE to
 several syscalls
Message-ID: <20120711150039.08845e85@tlielax.poochiereds.net>
In-Reply-To: <1342032143.2190.22.camel@iscandar.digidescorp.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
	<1342032143.2190.22.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Jul 2012 13:42:23 -0500
"Steven J. Magnani" <steve@digidescorp.com> wrote:

> Jeff -
> 
> On Fri, 2012-06-29 at 14:57 -0400, Jeff Layton wrote: 
> > This patchset is the third version of the patchset to add ESTALE
> > handling to several syscalls. The basic idea is to allow the client to
> > gracefully retry the lookup and call when a NFS server returns ESTALE.
> 
> I exercised this using 3.5-rc5 against a memory-starved server that
> exports a FAT-backed filesystem. Where normally I see lots of ESTALE
> errors due to inode eviction, with this patchset I see none. And, the
> performance is much better than the only other way I know to eliminate
> the errors, which is to mount with 'lookupcache=none'.
> 
> It's not an exhaustive test by any means, just a data point for you. 
> Thanks!
> 
> Lightly-tested-by: Steve Magnani <steve@digidescorp.com>

Awesome -- thanks for testing it.

Yeah "lookupcache=none" has been the standard answer for people
suffering from ESTALE problems, but the perf hit can be quite nasty.
Avoiding that is one of the main drivers for handling ESTALE this way.

With luck, we'll see at least some of this set go in for 3.6.

-- 
Jeff Layton <jlayton@redhat.com>
