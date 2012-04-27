Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:17967 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751729Ab2D0Av0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 20:51:26 -0400
Date: Fri, 27 Apr 2012 10:51:21 +1000
From: Dave Chinner <david@fromorbit.com>
To: David Howells <dhowells@redhat.com>
Cc: Andreas Dilger <adilger@dilger.ca>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended
 file stats available
Message-ID: <20120427005121.GD9541@dastard>
References: <5D4BF4AB-47E9-4E25-B2A3-F895C98BDAA3@dilger.ca>
 <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
 <18195.1335447156@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <18195.1335447156@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 02:32:36PM +0100, David Howells wrote:
> Andreas Dilger <adilger@dilger.ca> wrote:
> > st_blksize may be variable for a distributed filesystem,

It can be variable for local filesystems, too. XFS will vary the
block size based on the configuration of the inode. e.g. if there is
an extent allocation size hint on the inode, or it's on the realtime
device, and so on. There is no guarantee that from file to file that
it is constant.

> I wonder if there's a way to make this explicit - or is it something that if
> the bit isn't set, you can't use the value in st_blksize.
> I wonder if this
> value always has to be non-zero to make sure existing stat() doesn't explode.

More likely it probably needs to be non-zero to prevent applications
doing division by block size from exploding... ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
