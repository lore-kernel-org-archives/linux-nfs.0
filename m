From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Tue, 25 Aug 2009 14:59:12 -0400
Message-ID: <CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>
References: <4A9424DB.2040303@RedHat.com> <4A942593.8030101@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A942593.8030101@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 25, 2009, at 1:55 PM, Steve Dickson wrote:
> commit 1471d23d692efc7388794a8a3c3b9e548d1c5be8
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Aug 25 12:15:18 2009 -0400
>
>    Make sure umount use correct fs type.
>
>    umounts use the fs type in /etc/mtab to determine
>    which file system is being unmounted. The mtab
>    entry is create during the mount. To ensure the
>    correct entry is create when the fs type changes
>    due to the mount options, the address of the fs_type
>    variable has to be passed so it can be updated.

In general, my policy is to record the user requested mount options  
in /etc/mtab, and let umount.nfs handle renegotiating as needed.  For  
version/transport this means that the server's configuration can  
change between the mount and the umount, and the umount will still work.

Perhaps this is not a consideration for NFSv4, but leaving the mount  
options as specified by the user would save the need to update the fs  
type, and would be a consistent policy for v2, v3, and v4.  I think it  
would be cleaner to teach umount.nfs to do the right thing with "-t  
nfs -o v4" rather than rewriting the options in /etc/mtab.

>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index 355df79..507fbb5 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -417,13 +417,14 @@ static int chk_mountpoint(char *mount_point)
> }
>
> static int try_mount(char *spec, char *mount_point, int flags,
> -			char *fs_type, char **extra_opts, char *mount_opts,
> +			char *type, char **extra_opts, char *mount_opts,
> 			int fake, int bg)
> {
> 	int ret;
> +	char *fs_type = type;
>
> 	if (string)
> -		ret = nfsmount_string(spec, mount_point, fs_type, flags,
> +		ret = nfsmount_string(spec, mount_point, &fs_type, flags,
> 					extra_opts, fake, bg);
> 	else {
> 		if (strcmp(fs_type, "nfs4") == 0)
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 153723d..1031c08 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -734,13 +734,13 @@ static int nfsmount_start(struct nfsmount_info  
> *mi)
>  * @fake: flag indicating whether to carry out the whole operation
>  * @child: one if this is a mount daemon (bg)
>  */
> -int nfsmount_string(const char *spec, const char *node, const char  
> *type,
> +int nfsmount_string(const char *spec, const char *node, char **type,
> 		    int flags, char **extra_opts, int fake, int child)
> {
> 	struct nfsmount_info mi = {
> 		.spec		= spec,
> 		.node		= node,
> -		.type		= type,
> +		.type		= *type,
> 		.extra_opts	= extra_opts,
> 		.flags		= flags,
> 		.fake		= fake,
> @@ -751,6 +751,9 @@ int nfsmount_string(const char *spec, const char  
> *node, const char *type,
> 	mi.options = po_split(*extra_opts);
> 	if (mi.options) {
> 		retval = nfsmount_start(&mi);
> +		/* Note any fs type changes */
> +		if (!retval)
> +			*type =  (char *)mi.type;
> 		po_destroy(mi.options);
> 	} else
> 		nfs_error(_("%s: internal option parsing error"), progname);
> diff --git a/utils/mount/stropts.h b/utils/mount/stropts.h
> index b4fd888..dad9997 100644
> --- a/utils/mount/stropts.h
> +++ b/utils/mount/stropts.h
> @@ -24,7 +24,7 @@
> #ifndef _NFS_UTILS_MOUNT_STROPTS_H
> #define _NFS_UTILS_MOUNT_STROPTS_H
>
> -int nfsmount_string(const char *, const char *, const char *, int,
> +int nfsmount_string(const char *, const char *, char **, int,
> 			char **, int, int);
>
> #endif	/* _NFS_UTILS_MOUNT_STROPTS_H */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
