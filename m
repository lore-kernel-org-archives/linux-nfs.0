Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52400 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751040AbdJLOVK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 10:21:10 -0400
Subject: Re: [PATCH] nfs(5): update some version information
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20171011160243.GG25913@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <93f59205-adaa-2794-f3a3-e604c33ef1f1@RedHat.com>
Date: Thu, 12 Oct 2017 10:21:09 -0400
MIME-Version: 1.0
In-Reply-To: <20171011160243.GG25913@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/11/2017 12:02 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We've seen some confusion from people not understanding why newer
> clients may not support NFSv2.  It might help a little to note in the
> man page that version support depends on how the kernel was built.
> 
> While we're there:
> 
> 	- update some references to NFS protocol versions.
> 	- update 4.0 RFC, and add references to 4.1 and 4.2 RFCs.
> 	- rename "BUGS" to "NOTES"; the section mostly isn't about bugs.
> 	  (Might be time to remove some of the linux-2.4 notes too.)
> 	- remove some outdated references to optional NFSv4+ features.
> 	  (Or should we try to keep this information up to date?)
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed... 

steved.
> ---
>  utils/mount/nfs.man | 35 ++++++++++++++++++++---------------
>  1 file changed, 20 insertions(+), 15 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 7d42f19d0ca6..bd1508c6154d 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -11,11 +11,8 @@ NFS is an Internet Standard protocol
>  created by Sun Microsystems in 1984. NFS was developed
>  to allow file sharing between systems residing
>  on a local area network.
> -The Linux NFS client supports three versions
> -of the NFS protocol:
> -NFS version 2 [RFC1094],
> -NFS version 3 [RFC1813],
> -and NFS version 4 [RFC3530].
> +Depending on kernel configuration, the Linux NFS client may
> +support NFS versions 2, 3, 4.0, 4.1, or 4.2.
>  .P
>  The
>  .BR mount (8)
> @@ -88,9 +85,8 @@ These options are valid to use with any NFS version.
>  The NFS protocol version number used to contact the server's NFS service.
>  If the server does not support the requested version, the mount request 
>  fails.
> -If this option is not specified, the client negotiates a suitable version 
> -with
> -the server, trying version 4 first, version 3 second, and version 2 last.
> +If this option is not specified, the client tries version 4.2 first,
> +then negotiates down until it finds a version supported by the server.
>  .TP 1.5i
>  .BI vers= n
>  This option is an alternative to the
> @@ -762,7 +758,7 @@ NOTE: When used together, the 'local_lock' mount option will be overridden
>  by 'nolock'/'lock' mount option.
>  .SS "Options for NFS version 4 only"
>  Use these options, along with the options in the first subsection above,
> -for NFS version 4 and newer.
> +for NFS version 4.0 and newer.
>  .TP 1.5i
>  .BI proto= netid
>  The
> @@ -835,7 +831,7 @@ the behavior of this option in more detail.
>  Specifies a single IPv4 address (in dotted-quad form),
>  or a non-link-local IPv6 address,
>  that the NFS client advertises to allow servers
> -to perform NFS version 4 callback requests against
> +to perform NFS version 4.0 callback requests against
>  files on this mount point. If  the  server is unable to
>  establish callback connections to clients, performance
>  may degrade, or accesses to files may temporarily hang.
> @@ -848,6 +844,11 @@ In the presence of multiple client network interfaces,
>  special routing policies,
>  or atypical network topologies,
>  the exact address to use for callbacks may be nontrivial to determine.
> +.IP
> +NFS protocol versions 4.1 and 4.2 use the client-established
> +TCP connection for callback requests, so do not require the server to
> +connect to the client.  This option is therefore only affect NFS version
> +4.0 mounts.
>  .TP 1.5i
>  .BR migration " / " nomigration
>  Selects whether the client uses an identification string that is compatible
> @@ -1789,7 +1790,7 @@ file system table
>  .TP 1.5i
>  .I /etc/nfsmount.conf
>  Configuration file for NFS mounts
> -.SH BUGS
> +.SH NOTES
>  Before 2.4.7, the Linux NFS client did not support NFS over TCP.
>  .P
>  Before 2.4.20, the Linux NFS client used a heuristic
> @@ -1808,9 +1809,9 @@ when the
>  .BR rsize " and " wsize
>  settings were smaller than the system's page size.
>  .P
> -The Linux NFS client does not yet support
> -certain optional features of the NFS version 4 protocol,
> -such as security negotiation, server referrals, and named attributes.
> +The Linux client's support for protocol versions depend on whether the
> +kernel was built with options CONFIG_NFS_V2, CONFIG_NFS_V3,
> +CONFIG_NFS_V4, CONFIG_NFS_V4_1, and CONFIG_NFS_V4_2.
>  .SH "SEE ALSO"
>  .BR fstab (5),
>  .BR mount (8),
> @@ -1843,4 +1844,8 @@ RFC 1833 for the RPC bind specification.
>  .br
>  RFC 2203 for the RPCSEC GSS API protocol specification.
>  .br
> -RFC 3530 for the NFS version 4 specification.
> +RFC 7530 for the NFS version 4.0 specification.
> +.br
> +RFC 5661 for the NFS version 4.1 specification.
> +.br
> +RFC 7862 for the NFS version 4.2 specification.
> 
