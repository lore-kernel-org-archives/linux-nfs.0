Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:56047 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911Ab0H3Qyp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:54:45 -0400
Subject: Re: [patch] fix description of nfsversion mount option
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C79402F.7040204@inria.fr>
Date: Mon, 30 Aug 2010 12:54:24 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <5E3BF723-4924-43DE-BF4B-7D1DE3ABF4D5@oracle.com>
References: <4C66ADF2.9030700@inria.fr> <4C6B03DE.5040105@RedHat.com> <4C79402F.7040204@inria.fr>
To: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 28, 2010, at 12:58 PM, Guillaume Rousse wrote:

> Le 17/08/2010 23:49, Steve Dickson a écrit :
>> 
>> 
>> On 08/14/2010 10:53 AM, Guillaume Rousse wrote:
>>> Hello list.
>>> 
>>> Here is a first patch trying to update a little bit nfs-utils
>>> documentation. I'd like also to change the constant opposition of 'nfs'
>>> vs 'nfs4' filesystems in this man page, but I have no clue if the plan
>>> is to remove 'nfs4' filesystem completly, or to keep for compatibility
>>> purpose. In the first case, I'd just remove any occurence of it in the
>>> man page, in the second case, I'm less sure about what to do.
>> In the future please use the proper Signed-off-by: line in 
>> your patch... Its cool for this time, since the change is a 
>> minor one... 
> Here is a now one, dealing with protocol-specific versions. This time I
> found how to add the signoff header in git documentation :)
> 
> BTW, I don't what what's the exact plan for the 'nfs4' filesystem type,
> so I just mentionned it as an old syntax. And I also supposed than
> protocol-specific versions would just get ignored when used with another
> version, but I'm not sure at all.
> -- 
> BOFH excuse #375:
> 
> Root name servers corrupted.
> <0001-Drop-reference-to-the-nfs4-filesystem-type-excepted-.patch>

Do not post patches as attachments.  Please post patches inline so we can easily hit "reply" and comment.  Thanks!

> From 95f5f0e1a5e1edf7a34a03ee3fecd8908fa1ddad Mon Sep 17 00:00:00 2001
> From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
> Date: Sat, 28 Aug 2010 18:50:43 +0200
> Subject: [PATCH] Drop reference to the nfs4 filesystem type, excepted as an older
>  syntax, and document options as specific to a protocol version
>  rather than to a filesystem type.

The Subject: field should be a short description (no more than 65 or so characters).  The body of the description should describe the patch.  What you have in the Subject: field here is a long description, and should go in the body.

Not a show stopper, but for future reference.

> Signed-off-by: Guillaume Rousse <Guillaume.Rousse@inria.fr>
> ---
>  utils/mount/nfs.man |   50 ++++++++++++++++++++------------------------------
>  1 files changed, 20 insertions(+), 30 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 3806635..fe58015 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -3,8 +3,6 @@
>  .SH NAME
>  nfs \- fstab format and options for the
>  .B nfs
> -and
> -.B nfs4
>  file systems

If you removed "nfs4" then "file systems" should be made singular.

>  .SH SYNOPSIS
>  .I /etc/fstab
> @@ -71,14 +69,10 @@ for details on specifying raw IPv6 addresses.
>  .P
>  The
>  .I fstype
> -field contains either "nfs" (for version 2 or version 3 NFS mounts)
> -or "nfs4" (for NFS version 4 mounts).
> +field contains "nfs", for whatever version of the protocol.

Since "nfs4" is still allowed and is not deprecated, I think a reference to it should remain here.

In general, I'd rather see an emphasis of "nfs vers=4" rather than removal of "nfs4" as "nfs4" still works and is supported for now.

>  The
>  .B nfs
> -and
> -.B nfs4
> -file system types share similar mount options,
> -which are described below.
> +allow several mount options, which are described below.
>  .SH "MOUNT OPTIONS"
>  Refer to
>  .BR mount (8)
> @@ -89,14 +83,8 @@ specify any mount options, use the generic option
>  in
>  .IR /etc/fstab .
>  .DT
> -.SS "Valid options for either the nfs or nfs4 file system type"
> -These options are valid to use when mounting either
> -.B nfs
> -or
> -.B nfs4
> -file system types.
> -They imply the same behavior
> -and have the same default for both file system types.
> +.SS "Options supported by all versions"
> +These options are valid to use with any NFS version.
>  .TP 1.5i
>  .BR soft " / " hard
>  Determines the recovery behavior of the NFS client
> @@ -476,11 +464,9 @@ by other clients, but can impact application and server performance.
>  .IP
>  The DATA AND METADATA COHERENCE section contains a
>  detailed discussion of these trade-offs.
> -.SS "Valid options for the nfs file system type"
> +.SS "Options for versions 2 and 3 only"

For clarity, I would prefer "Options for NFS versions 2 and 3 only" .

>  Use these options, along with the options in the above subsection,
> -for mounting the
> -.B nfs
> -file system type.
> +for NFSv2/v3 only. They will be ignored for newer versions.

I avoided version abbreviations when I originally wrote this, for clarity.  I think

 "for NFS versions 2 and 3 only.  They are ignored for newer versions."

Is more clear.  And, we like to avoid the use of future tense in documentation.

>  .TP 1.5i
>  .BI proto= netid
>  The transport protocol name and protocol family the NFS client uses
> @@ -722,11 +708,9 @@ If this option is not specified, the NFS client uses READDIRPLUS requests
>  on NFS version 3 mounts to read small directories.
>  Some applications perform better if the client uses only READDIR requests
>  for all directories.
> -.SS "Valid options for the nfs4 file system type"
> +.SS "Options for version 4 only"

As above: "Options for NFS version 4 only"

>  Use these options, along with the options in the first subsection above,
> -for mounting the
> -.B nfs4
> -file system type.
> +for NFSv4 only. They will be ignored with older versions.

Better: "for NFS version 4 only.  They are ignored with older NFS versions."

>  .TP 1.5i
>  .BI proto= netid
>  The transport protocol name and protocol family the NFS client uses
> @@ -823,6 +807,13 @@ In the presence of multiple client network interfaces,
>  special routing policies,
>  or atypical network topologies,
>  the exact address to use for callbacks may be nontrivial to determine.
> +.SH nfs4 FILE SYSTEM TYPE
> +The
> +.BR nfs4
> +file system type is an old syntax for specifying NFSv4 usage. It can still 
> +be used with all NFSv4-specific and common options, excepted the
> +.B nfsvers
> +mount option.

"nfs4" is not deprecated.  I think we need to keep it as a first class citizen until support for it is gone.  I'm OK with having a little section about the functional equivalence of "nfs vers=4" and "nfs4".  Let's avoid the term "old syntax" (usually we use a weaker term like "legacy" :-)

And, the usual comments about using "NFS version 4" rather than "NFSv4" apply.

How about:

".SH nfs4 FILE SYSTEM TYPE
The
.B nfs4
file system type is equivalent to using the
.B nfs
file system type and specifying the
.I vers=4
mount option.
Mount options that are common to all NFS versions, and options that can be
used only when
.I vers=4
is specified are appropriate for
.B nfs4
file systems.
The use of
.B nfs
with the
.I vers=4
mount option is encouraged."

>  .SH MOUNT CONFIGURATION FILE
>  If the mount command is configured to do so, all of the mount options 
>  described in the previous section can also be configured in the 
> @@ -844,12 +835,11 @@ file system type and specify the
>  .B nfsvers=3
>  mount option.
>  To mount using NFS version 4,
> -use the
> -.B nfs4
> -file system type.
> -The
> -.B nfsvers
> -mount option is not supported for the
> +use either the
> +.B nfs
> +file system type, with the

No comma is needed here.

> +.B nfsvers=4
> +mount option, or the 
>  .B nfs4
>  file system type.
>  .P
> -- 
> 1.7.2.2

-- 
chuck[dot]lever[at]oracle[dot]com




