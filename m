From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch] mount: check if mtab is writable
Date: Fri, 20 Jun 2008 12:44:25 -0400
Message-ID: <924D6C81-60EA-407C-ADCE-5774805D8659@oracle.com>
References: <485BBAB2.3010304@inria.fr>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4 <nfsv4@linux-nfs.org>
To: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <485BBAB2.3010304@inria.fr>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 20, 2008, at 10:12 AM, Guillaume Rousse wrote:
> --  
> Guillaume Rousse
> Moyens Informatiques - INRIA Futurs
> Tel: 01 69 35 69 62
> Signed-off-by: Christiaan Welvaart <spturtle@mandriva.org>
> --
> --- nfs-utils-1.1.1/utils/mount/mount.c.bak	2007-10-19  
> 05:07:28.000000000 +0200
> +++ nfs-utils-1.1.1/utils/mount/mount.c	2007-12-12  
> 20:27:45.054651566 +0100
> @@ -394,7 +394,7 @@
> 	if (!fake)
> 		print_one(spec, mount_point, fs_type, mount_opts);
>
> -	if (!nomtab)
> +	if (!nomtab && mtab_is_writable())
> 		ret = add_mtab(spec, mount_point, fs_type, flags, *extra_opts,
> 				0, 0 /* these are always zero for NFS */ );
> 	return ret;

I think the result of this change would be that if the mtab isn't  
writable (for example, if it's a symlink to /proc/mounts) then  
add_mtab() wouldn't print an error message saying it couldn't write.   
That seems harmless enough.

Looking at the shared routine update_mtab(), the first thing it does  
is check if the mtab exists and is writable.  That check should  
probably be copied to utils/mount/mount.c:add_mtab() instead of using  
this patch.

I might even advocate moving add_mtab to support/nfs/fstab.c.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
