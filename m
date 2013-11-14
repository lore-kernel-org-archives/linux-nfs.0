Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:54769 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758194Ab3KNWLb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 17:11:31 -0500
Date: Fri, 15 Nov 2013 09:11:26 +1100
From: Dave Chinner <david@fromorbit.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, libc-alpha@sourceware.org,
        linux-api@vger.kernel.org, andreas.gruenbacher@gmail.com,
        samba-technical@lists.samba.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/3] statxat: Provide IOC flags for Windows fs attributes
 [ver #2]
Message-ID: <20131114221126.GE11434@dastard>
References: <20131112184127.2880.24025.stgit@warthog.procyon.org.uk>
 <20131112184134.2880.9974.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131112184134.2880.9974.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 12, 2013 at 06:41:35PM +0000, David Howells wrote:
> Provide IOC flags for Windows fs attributes so that they can be retrieved (or
> even altered) using the FS_IOC_[GS]ETFLAGS ioctl and read using statxat().

If you're adding FAT specific flags here into the generic xstat
interface, can we get a bunch of common XFS specific flags into this
interface as well so people don't need to use xfs_io to get/set
them?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
