Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa11.utexas.iphmx.com ([216.71.154.254]:12312 "EHLO
        esa11.utexas.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbeC2QpZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2018 12:45:25 -0400
Subject: Re: client side see wrong directory entries with nfs_export on
 overlayfs
To: Jeff Layton <jlayton@kernel.org>,
        Amir Goldstein <amir73il@gmail.com>,
        Dai Qizhi <qzdai@clustertech.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>
References: <20180327182450.38D9.733CD922@clustertech.com>
 <CAOQ4uxgtD1F_S_tGoAKo7egqbXRGa-sM6SL-Ab7K62LN0FYBSA@mail.gmail.com>
 <20180328091413.38DF.733CD922@clustertech.com>
 <CAOQ4uxgZd7qC2xW3pYNYKqrpVJYBDRovyeAkeySWLjM4+WhGxw@mail.gmail.com>
 <1522235739.18706.13.camel@kernel.org>
From: Patrick Goetz <pgoetz@math.utexas.edu>
Message-ID: <795e539b-21e5-be97-d464-6dd087318f48@math.utexas.edu>
Date: Thu, 29 Mar 2018 11:35:53 -0500
MIME-Version: 1.0
In-Reply-To: <1522235739.18706.13.camel@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/28/2018 06:15 AM, Jeff Layton wrote:
> Long, long ago, the fsid for the export was almost always determined by
> the device major/minor tuple. That became really problematic whenever
> devices got reordered after adding a disk to the system and rebooting.
> So, Neil Brown added the ability to determine the fsid from the
> libblkdev uuid (see nfs-utils commit e91ff0175602c, and kernel commits
> from around that time).
> 

I recently got burned by this because it appears that bind-mounted XFS 
exports are somehow different from bind-mounted ext4 exports?  I.e. I 
was able to export one bind mounted filesystem (under an NFS4 root 
export) with no fsid, but when I tried to add another one (also a bind 
mount under the same root), the export failed in an odd way.  The only 
difference was in the first case the underlying filesystem was ext4 and 
the other XFS.  I'll post a question about this later, but for now ...

This seems like bad design.  Wouldn't it make more sense to require that 
an fsid be assigned to all exports? Then there's no question in the 
user's mind of do I need an fsid or don't I?




