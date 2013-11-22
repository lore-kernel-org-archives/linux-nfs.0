Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:36290 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099Ab3KVQx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Nov 2013 11:53:27 -0500
Message-ID: <528F8C01.8020603@codethink.co.uk>
Date: Fri, 22 Nov 2013 10:53:21 -0600
From: Mark Doffman <mark.doffman@codethink.co.uk>
MIME-Version: 1.0
To: David Dillow <dave@thedillows.org>
CC: ceph-devel@vger.kernel.org, sage@inktank.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        rob.taylor@codethink.co.uk
Subject: Re: [PATCH 0/4] Add ceph root filesystem functionality and documentation.
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk> <1385065186.18238.0.camel@frustration.ornl.gov>
In-Reply-To: <1385065186.18238.0.camel@frustration.ornl.gov>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/21/2013 02:19 PM, David Dillow wrote:
> On Wed, 2013-11-20 at 20:13 -0600, mark.doffman@codethink.co.uk wrote:
>> The following patch series adds the ability to use a ceph distributed
>> file system as the root device. The functionality is similar to
>> NFS root but for the ceph filesystem.
>
> Why do this in the kernel vs in the initramfs? Dracut would be a more
> appropriate place, I think, as it has support for other network root
> devices already.

I don't know if its a good idea to require an initramfs for mounting a
rootfs over the network. NFS root is currently in the kernel, and
frequently used without an initramfs.

Booting from ceph using a root device is relatively simple compared to
generating an initramfs and it has the possibility of producing smaller
images for memory constrained devices.


