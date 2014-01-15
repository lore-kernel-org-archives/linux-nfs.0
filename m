Return-Path: linux-nfs-owner@vger.kernel.org
Received: from merlin.infradead.org ([205.233.59.134]:44924 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbaAOSAZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jan 2014 13:00:25 -0500
Message-ID: <52D6CCD4.5080104@infradead.org>
Date: Wed, 15 Jan 2014 10:00:52 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
To: mark.doffman@codethink.co.uk
CC: ceph-devel@vger.kernel.org, Rob Taylor <rob.taylor@codethink.co.uk>,
        sage@inktank.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] Documentation: Document the cephroot functionality
References: <cover.1389806186.git.mark.doffman@codethink.co.uk> <29b3bd9700e23df2aee095df8c34a15a62f57d27.1389806186.git.mark.doffman@codethink.co.uk>
In-Reply-To: <29b3bd9700e23df2aee095df8c34a15a62f57d27.1389806186.git.mark.doffman@codethink.co.uk>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/15/2014 09:26 AM, mark.doffman@codethink.co.uk wrote:
> From: Rob Taylor <rob.taylor@codethink.co.uk>
>
> Document using the cephfs as a root device, its purpose,
> functionality and use.
>
> Signed-off-by: Mark Doffman <mark.doffman@codethink.co.uk>
> Signed-off-by: Rob Taylor <rob.taylor@codethink.co.uk>
> Reviewed-by: Ian Molton <ian.molton@codethink.co.uk>
> ---
>   Documentation/filesystems/{ => ceph}/ceph.txt |  0
>   Documentation/filesystems/ceph/cephroot.txt   | 86 +++++++++++++++++++++++++++
>   2 files changed, 86 insertions(+)
>   rename Documentation/filesystems/{ => ceph}/ceph.txt (100%)
>   create mode 100644 Documentation/filesystems/ceph/cephroot.txt
>
> diff --git a/Documentation/filesystems/ceph.txt b/Documentation/filesystems/ceph/ceph.txt
> similarity index 100%
> rename from Documentation/filesystems/ceph.txt
> rename to Documentation/filesystems/ceph/ceph.txt
> diff --git a/Documentation/filesystems/ceph/cephroot.txt b/Documentation/filesystems/ceph/cephroot.txt
> new file mode 100644
> index 0000000..deda4f0
> --- /dev/null
> +++ b/Documentation/filesystems/ceph/cephroot.txt
> @@ -0,0 +1,86 @@
> +Mounting the root filesystem via Ceph (cephroot)
> +===============================================
> +
> +Written 2013 by Rob Taylor <rob.taylor@codethink.co.uk>
> +
> +derived from nfsroot.txt:
> +
> +Written 1996 by Gero Kuhlmann <gero@gkminix.han.de>
> +Updated 1997 by Martin Mares <mj@atrey.karlin.mff.cuni.cz>
> +Updated 2006 by Nico Schottelius <nico-kernel-nfsroot@schottelius.org>
> +Updated 2006 by Horms <horms@verge.net.au>
> +
> +
> +
> +In order to use a diskless system, such as an X-terminal or printer server
> +for example, it is necessary for the root filesystem to be present on a
> +non-disk device. This may be an initramfs (see Documentation/filesystems/
> +ramfs-rootfs-initramfs.txt), a ramdisk (see Documentation/initrd.txt), a
> +filesystem mounted via NFS or a filesystem mounted via Ceph. The following
> +text describes on how to use Ceph for the root filesystem.
> +
> +For the rest of this text 'client' means the diskless system, and 'server'
> +means the Ceph server.
> +
> +
> +1.) Enabling cephroot capabilities
> +    -----------------------------
> +
> +In order to use cephroot, CEPH_FS needs to be selected as
> +built-in during configuration. Once this has been selected, the cephroot
> +option will become available, which should also be selected.
> +
> +In the networking options, kernel level autoconfiguration can be selected,
> +along with the types of autoconfiguration to support. Selecting all of
> +DHCP, BOOTP and RARP is safe.
> +
> +
> +2.) Kernel command line
> +    -------------------
> +
> +When the kernel has been loaded by a boot loader (see below) it needs to be
> +told what root fs device to use. And in the case of cephroot, where to find

                                use, and

> +both the server and the name of the directory on the server to mount as root.
> +This can be established using the following kernel command line parameters:
> +
> +root=/dev/ceph
> +
> +This is necessary to enable the pseudo-Ceph-device. Note that it's not a
> +real device but just a synonym to tell the kernel to use Ceph instead of
> +a real device.
> +
> +If cephroot is not specified, it is expected that that a valid mount will be

drop duplicate:                                 that

> +found via DHCP option 17, Root Path [1]
> +
> +cephroot=<monaddrs>:/[<subdir>],<ceph-opts>
> +
> +  <monaddrs>    Monitor addresses separated by commas. Each takes the form
> +		host[:port]. If the port is not specified, the Ceph default
> +		of 6789 is assumed.
> +
> +  <subdir>	A subdirectory subdir may be specified if a subset of the file
> +		system is to be mounted

		                mounted.
		
> +
> +  <ceph-opts>	Standard Ceph options. All options are separated by commas.
> +		See Documentation/filesystems/ceph/ceph.txt for options and
> +		their defaults.
> +
> +4.) References
> +    ----------
> +
> +[1] http://tools.ietf.org/html/rfc2132
> +
> +5.) Credits
> +    -------
> +
> +  cephroot was derived from nfsroot by Rob Taylor <rob.taylor@codethink.co.uk>
> +  and Mark Doffman <mark.doffman@codethink.co.uk>
> +
> +  The nfsroot code in the kernel and the RARP support have been written
> +  by Gero Kuhlmann <gero@gkminix.han.de>.
> +
> +  The rest of the IP layer autoconfiguration code has been written
> +  by Martin Mares <mj@atrey.karlin.mff.cuni.cz>.
> +
> +  In order to write the initial version of nfsroot I would like to thank
> +  Jens-Uwe Mager <jum@anubis.han.de> for his help.
>


-- 
~Randy
