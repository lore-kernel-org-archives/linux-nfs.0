Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mta01.ornl.gov ([128.219.177.14]:60772 "EHLO mta01.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab3KUU3l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Nov 2013 15:29:41 -0500
Message-ID: <1385065186.18238.0.camel@frustration.ornl.gov>
Subject: Re: [PATCH 0/4] Add ceph root filesystem functionality and
 documentation.
From: David Dillow <dave@thedillows.org>
To: mark.doffman@codethink.co.uk
Cc: ceph-devel@vger.kernel.org, sage@inktank.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        rob.taylor@codethink.co.uk
Date: Thu, 21 Nov 2013 15:19:46 -0500
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-11-20 at 20:13 -0600, mark.doffman@codethink.co.uk wrote:
> The following patch series adds the ability to use a ceph distributed
> file system as the root device. The functionality is similar to
> NFS root but for the ceph filesystem.

Why do this in the kernel vs in the initramfs? Dracut would be a more
appropriate place, I think, as it has support for other network root
devices already.

