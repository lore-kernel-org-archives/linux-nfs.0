Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.digidescorp.com ([50.73.98.161]:25587 "EHLO
	mail.digidescorp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab2GKSoQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 14:44:16 -0400
Message-ID: <1342032143.2190.22.camel@iscandar.digidescorp.com>
Subject: Re: [PATCH v3 00/17] vfs: add the ability to retry on ESTALE to
 several syscalls
From: "Steven J. Magnani" <steve@digidescorp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        michael.brantley@deshaw.com, hch@infradead.org, miklos@szeredi.hu,
        pstaubach@exagrid.com
Date: Wed, 11 Jul 2012 13:42:23 -0500
In-Reply-To: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff -

On Fri, 2012-06-29 at 14:57 -0400, Jeff Layton wrote: 
> This patchset is the third version of the patchset to add ESTALE
> handling to several syscalls. The basic idea is to allow the client to
> gracefully retry the lookup and call when a NFS server returns ESTALE.

I exercised this using 3.5-rc5 against a memory-starved server that
exports a FAT-backed filesystem. Where normally I see lots of ESTALE
errors due to inode eviction, with this patchset I see none. And, the
performance is much better than the only other way I know to eliminate
the errors, which is to mount with 'lookupcache=none'.

It's not an exhaustive test by any means, just a data point for you. 
Thanks!

Lightly-tested-by: Steve Magnani <steve@digidescorp.com>
------------------------------------------------------------------------
Steven J. Magnani               "I claim this network for MARS!
www.digidescorp.com              Earthling, return my space modulator!"

#include <standard.disclaimer>


