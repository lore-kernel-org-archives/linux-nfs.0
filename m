Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:51952 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064Ab0LQEKD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Dec 2010 23:10:03 -0500
Date: Thu, 16 Dec 2010 23:10:01 -0500
From: Jim Rees <rees@umich.edu>
To: Mike <debian@good-with-numbers.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-common needed on NFS-rooted client?
Message-ID: <20101217041001.GB9328@merit.edu>
References: <20101216230622.GA23016@adsl-64-142-29-25.sonic.net>
 <20101217020906.GA8853@merit.edu>
 <20101217031854.GA25106@adsl-64-142-29-25.sonic.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101217031854.GA25106@adsl-64-142-29-25.sonic.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Mike wrote:

  > The mount command also might be needed to update /etc/mtab if you don't have
  > it linked to /proc.  Does "mount" return the expected results?
  
  The kernel root mount is in /proc/mounts, but not in "mount"'s output.
  A rootfs at / is present in both.

You could fix that, if you care, by linking /proc/mounts to /etc/mtab.  But
if you've got the rootfs entry then things like "df" are probably ok, so it
might not matter.

Other than that, I can't think of any reason you really need nfs-common,
especially since you say it works without.  Not having the man page for the
mount options might be your biggest problem.  Google "nfs mount options"
will fix that.
