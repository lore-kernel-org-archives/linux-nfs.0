From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs(5): Document remount behavior (take 3)
Date: Mon, 01 Nov 2010 08:12:00 -0400
Message-ID: <4CCEAE90.70309@RedHat.com>
References: <20101029163746.5646.31637.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755651Ab0KAMMD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Nov 2010 08:12:03 -0400
In-Reply-To: <20101029163746.5646.31637.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/29/2010 12:40 PM, Chuck Lever wrote:
> It appears that, for a long while, NFS "remount" mounts have
> completely wiped the existing mount options in /etc/mtab for a given
> mount point.  This is a problem for umount.nfs, since it reads its
> options out of /etc/mtab to find out how to do the unmount.
> 
> The mount(8) command provides the NFS mount subcommand with the mount
> options to perform the remount.  There are four cases to consider:
> 
>   1. Both the device and mount directory are specified on the
>      command line, and the target mount point is in /etc/fstab
> 
>   2. Only one of the device and mount directory is specified on
>      the command line, and the target mount point is in
>      /etc/fstab
> 
>   3. Both the device and mount directory are specified on the
>      command line, and the target mount point is not in /etc/fstab
> 
>   4. Only one of the device and mount directory is specified on
>      the command line, and the target mount point is not in
>      /etc/fstab
> 
> Currently only case 4 works correctly.  In that case, mount(8)
> provides the correct set of mount options to the mount.nfs
> subcommand and it can update /etc/mtab correctly.
> 
> Cases 1 and 3 replace all mount options in /etc/mtab with the options
> provided on the command line during a remount.  Case 2 replaces the
> mount options in /etc/mtab with a mix of options from /etc/fstab and
> /etc/mtab.
> 
> Cases 1 and 3 are historical behavior.  Basically this is a formal
> interface to allow administrators to replace the mount options in
> /etc/mtab completely, instead of merging in new ones.  The present
> patch documents that behavior in nfs(5), and provides best practice
> for remounting NFS mount points.
> 
> There are near-term plans to address case 2 by fixing mount(8)
> (provided by utils-linux-ng in most distributions).
> 
> This is a partial fix for:
> 
>   https://bugzilla.linux-nfs.org/show_bug.cgi?id=188
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed...

steved.

> ---
> 
> Take 3:
> 
>   o  Actually commit the patch before trying to e-mail it
> 
>   o  Remove all mention of /etc/mtab
> 
>   o  Refocus umount discussion on umount requirements rather
>      than remount behavior
> 
>  utils/mount/nfs.man |   54 ++++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 38 insertions(+), 16 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 1b86768..be91a25 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -1523,32 +1523,54 @@ of Access Control Lists that are semantically richer than POSIX ACLs.
>  NFS version 4 ACLs are not fully compatible with POSIX ACLs; as such,
>  some translation between the two is required
>  in an environment that mixes POSIX ACLs and NFS version 4.
> -.SH FILES
> -.TP 1.5i
> -.I /etc/fstab
> -file system table
> -.SH BUGS
> -The generic
> -.B remount
> -option is not fully supported.
> -Generic options, such as
> -.BR rw " and " ro
> -can be modified using the
> -.B remount
> -option,
> -but NFS-specific options are not all supported.
> +.SH "THE REMOUNT OPTION"
> +Generic mount options such as
> +.BR rw " and " sync
> +can be modified on NFS mount points using the
> +.BR remount
> +option.
> +See
> +.BR mount (8)
> +for more information on generic mount options.
> +.P
> +With few exceptions, NFS-specific options
> +are not able to be modified during a remount.
>  The underlying transport or NFS version
>  cannot be changed by a remount, for example.
> +.P
>  Performing a remount on an NFS file system mounted with the
>  .B noac
>  option may have unintended consequences.
>  The
>  .B noac
> -option is a mixture of a generic option,
> +option is a combination of the generic option
>  .BR sync ,
> -and an NFS-specific option
> +and the NFS-specific option
>  .BR actimeo=0 .
> +.SS "Unmounting after a remount"
> +For mount points that use NFS versions 2 or 3, the NFS umount subcommand
> +depends on knowing the original set of mount options used to perform the
> +MNT operation.
> +These options are stored on disk by the NFS mount subcommand,
> +and can be erased by a remount.
>  .P
> +To ensure that the saved mount options are not erased during a remount,
> +specify either the local mount directory, or the server hostname and
> +export pathname, but not both, during a remount.  For example,
> +.P
> +.NF
> +.TA 2.5i
> +	mount -o remount,ro /mnt
> +.FI
> +.P
> +merges the mount option
> +.B ro
> +with the mount options already saved on disk for the NFS server mounted at /mnt.
> +.SH FILES
> +.TP 1.5i
> +.I /etc/fstab
> +file system table
> +.SH BUGS
>  Before 2.4.7, the Linux NFS client did not support NFS over TCP.
>  .P
>  Before 2.4.20, the Linux NFS client used a heuristic
> 
