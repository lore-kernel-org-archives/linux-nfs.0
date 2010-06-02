Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56905 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755903Ab0FBD4Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jun 2010 23:56:25 -0400
Subject: Re: NFS exporting btrfs subvolumes.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Cc: linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org, jeffm@suse.com
In-Reply-To: <20100602134145.0d523a75@notabene.brown>
References: <20100602134145.0d523a75@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Jun 2010 23:56:20 -0400
Message-ID: <1275450980.4509.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-06-02 at 13:41 +1000, Neil Brown wrote:
> NFS needs a unique identifier for a filesystem to be able to export it.
<snip>
> Can anyone suggest a better way to get a good uuid for a btrfs filesystem?

How about just adding the btrfs subvolid to the filehandle and using
that to remove the ambiguity?

Cheers
   Trond

