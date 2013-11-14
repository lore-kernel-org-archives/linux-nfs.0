Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:24880 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab3KNDLr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 22:11:47 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: please proof-read: updates to nfs.man for some missing options.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131114140244.6f7c0094@notabene.brown>
Date: Wed, 13 Nov 2013 22:11:39 -0500
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Message-Id: <B7734C26-E989-4616-A1F3-F5BD05B12573@oracle.com>
References: <20131114140244.6f7c0094@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 13, 2013, at 10:02 PM, NeilBrown <neilb@suse.de> wrote:

> 
> Hi,
> I recently noticed that "man nfs" doesn't mention the "bsize" option.  So I
> looked more closely and found a few other options that the kernel supports
> but the man page doesn't mention.
> 
> I've added documentation for most of them - leaving off "posix" and "noposix"
> as it looks like they are not used and never have been.
> 
> Possibly I should have left out "sloppy" too as it is (I think) just an
> "internal" form of the "-s" flag.  Opinions on that are welcome.
> 
> The others I've researched and documented to the best of my ability, but I
> would appreciate review (just to make sure I never typed 'now' where I meant
> 'not' as I usually do).
> 
> In particular I made up some details for the "migration" option and hope
> Chuck will set me straight if I'm leading the reader astray - thanks Chuck.
> (Obviously I work with RAID too much .. I typed "chunk" twice above and had
> to correct both of them.  You see what I mean about needing proof-readers).

A lot of work here, thanks.

sloppy, addr= and mountaddr= are all internal and probably should not be documented because they are not meant to be used by humans.

bsize= I don't remember, but I think we decided not to document that one either?

migration already has a pending patch in my private repo, and maybe I've even posted that on list recently.  We were waiting on the final patches to be submitted, which were merged in 3.12 last week.  I can post that again.

fsc= is Dave Howells' baby, he should probably have a look-see.

The additional negotiation behavior is somewhat new, probably a good thing to update here.


> 
> Thanks in advance,
> NeilBrown
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 2a42b9340905..7786e6fd3d0d 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -90,7 +90,14 @@ If the server does not support the requested version, the mount request
> fails.
> If this option is not specified, the client negotiates a suitable version 
> with
> -the server, trying version 4 first, version 3 second, and version 2 last.
> +the server, trying version 4.0, then version 3.  Version 2 is never
> +attempted unless explicitly requested.
> +.IP
> +NFS version 4 has multiple sub-versions which can be requested using a
> +suffix such as 4.1 or 4.2 if the kernel is Linux 3.4 or later, or by
> +using the
> +.B minorversion
> +option for earlier kernels.
> .TP 1.5i
> .BI vers= n
> This option is an alternative to the
> @@ -248,6 +255,17 @@ value negotiated by the client and server is reported in the
> .I /proc/mounts
> file.
> .TP 1.5i
> +.BI bsize= n
> +The block size that NFS should report.  This particularly affects the
> +numbers reported by
> +.IR statfs (2)
> +and
> +.IR df (1).
> +If not specified, the
> +.B wsize
> +value will be used, but will be clamped to a minimum of 1K and a
> +maximum of 1M.
> +.TP 1.5i
> .BR ac " / " noac
> Selects whether the client may cache file attributes. If neither
> option is specified (or if
> @@ -489,6 +507,23 @@ using the FS-Cache facility. See cachefilesd(8)
> and <kernel_soruce>/Documentation/filesystems/caching
> for detail on how to configure the FS-Cache facility.
> Default value is nofsc.
> +.TP 1.5i
> +.BR fsc= "unique string"
> +When the
> +.B nosharecache
> +option is used, only one of several mounts that aren't sharing a cache
> +will usually be permitted to use FS-Cache as there is no mechanism to
> +locate distinct disk caches for each mount.  This restriction can be
> +over come by providing an arbitrary "unique string" to each mount
> +which uses
> +.BR nosharecache .
> +.TP 1.5i
> +.B sloppy
> +This is equivalent to the
> +.B -s
> +option to
> +.IR mount (8)
> +and causes unexpected options to be ignored without error.
> .SS "Options for NFS versions 2 and 3 only"
> Use these options, along with the options in the above subsection,
> for NFS versions 2 and 3 only.
> @@ -552,6 +587,10 @@ The
> option is an alternative to specifying
> .BR proto=rdma.
> .TP 1.5i
> +.BR addr= ip-address
> +This option is rarely used but can provide an explicit IP address of
> +the NFS server in cases where the server is multi-homed.
> +.TP 1.5i
> .BI port= n
> The numeric value of the server's NFS service port.
> If the server's NFS service is not available on the specified port,
> @@ -617,6 +656,10 @@ If this option is not specified, the
> command assumes that the mountd service runs
> on the same host as the NFS service.
> .TP 1.5i
> +.BI mountaddr= ip-address
> +The IP address of the host running mountd.  This can be useful to
> +avoid ambiguity if the server running mountd has multiple addresses.
> +.TP 1.5i
> .BI mountvers= n
> The RPC version number used to contact the server's mountd.
> If this option is not specified, the client uses a version number
> @@ -780,6 +823,10 @@ so if this mount option is not specified, the NFS version 4 client
> uses the TCP protocol.
> Refer to the TRANSPORT METHODS section for more details.
> .TP 1.5i
> +.BR addr= ip-address
> +This option is rarely used but can provide an explicit IP address of
> +the NFS server in cases where the server is multi-homed.
> +.TP 1.5i
> .BI port= n
> The numeric value of the server's NFS service port.
> If the server's NFS service is not available on the specified port,
> @@ -855,6 +902,26 @@ In the presence of multiple client network interfaces,
> special routing policies,
> or atypical network topologies,
> the exact address to use for callbacks may be nontrivial to determine.
> +.TP 1.5i
> +.BR minorversion= number
> +This option was deprecated in Linux 3.4, but may be needed for older
> +kernels.  It specifies which minor version of the NFSv4 protocol to
> +use.  The preferred syntax for specifying a minor version is to use a
> +suffix with the
> +.B nfsvers
> +or
> +.B vers
> +options.
> +.TP 1.5i
> +.BR migration " / " nomigration
> +This should be used with an NFSv4.0 server if migration support is
> +required.  It is not necessary or permitted  for NFSv4.1 or later.
> +.IP
> +In order to support migration the NFS client must provide a
> +.I "uniform client string"
> +to the server.  This confuses some older NFSv4.0 servers so it is not
> +sent by default.  Servers that support migration must also support the
> +.IR "uniform client string" .
> .SH nfs4 FILE SYSTEM TYPE
> The
> .BR nfs4

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




