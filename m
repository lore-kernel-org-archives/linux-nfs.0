From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 1/5] NLM failover - nlm_unlock
Date: Fri, 18 Aug 2006 18:23:37 +1000
Message-ID: <1155889417.17651.436.camel@hole.melbourne.sgi.com>
References: <1155535055.3416.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDzdt-0003hc-9T
	for nfs@lists.sourceforge.net; Fri, 18 Aug 2006 01:23:49 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GDzds-0008T4-Fw
	for nfs@lists.sourceforge.net; Fri, 18 Aug 2006 01:23:49 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1155535055.3416.22.camel@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

G'day Wendy,

Your fsid-based approach does seem to make dropping locks
less fiddly than using the virtual server address.  Some
minor nits...

On Mon, 2006-08-14 at 15:57, Wendy Cheng wrote:
> By writing exported filesytem id into /proc/fs/nfsd/nlm_unlock, this
> patch walks thru lockd's global nlm_files list to release all the locks
> associated with the particular id. It is used to enable NFS lock
> failover with active-active clustered servers.
> [...]
>  static int
> -nlm_traverse_files(struct nlm_host *host, int action)
> +nlm_traverse_files(struct nlm_host *host, int *fsid_p, int action)
> [...]
>  {
>  	struct nlm_file	*file, **fp;
> -	int		i;
> +	int		i, rc, fsid, act=action;
>  
>  	mutex_lock(&nlm_file_mutex);
> +	if (fsid_p) fsid = *fsid_p;

I don't see any point initialising fsid like this, as you
throw away that value before ever using it.  Initialising
to zero should be enough to stop the compiler complaining.

> +				dprintk("lockd: drop lock file=0x%x fsid=%d\n",
> +					(int) file, fsid);

`file' is a pointer, and will not be the same size as an int 
on 64bit machines.  This is why %p exists, see examples in
the existing NLM code.

> @@ -253,6 +307,8 @@ nlm_traverse_files(struct nlm_host *host
>  			/* No more references to this file. Let go of it. */
>  			if (!file->f_blocks && !file->f_locks
>  			 && !file->f_shares && !file->f_count) {
> +				dprintk("lockd: fo_unlock close file=0x%x\n", 
> +					(int) file);

Ditto.

> @@ -90,6 +103,7 @@ static ssize_t (*write_op[])(struct file
>  	[NFSD_Getfd] = write_getfd,
>  	[NFSD_Getfs] = write_getfs,
>  	[NFSD_Fh] = write_filehandle,
> +	[NFSD_Nlm_unlock] = do_nlm_fo_unlock,
>  	[NFSD_Threads] = write_threads,
>  	[NFSD_Versions] = write_versions,
>  #ifdef CONFIG_NFSD_V4

All the other entries in write_op[] have a consistent naming
scheme, being called write_foo().

> @@ -334,6 +348,32 @@ static ssize_t write_filehandle(struct f
>  	return mesg - buf;	
>  }
>  
> +static ssize_t do_nlm_fo_unlock(struct file *file, char *buf, size_t size)
> +{
> +	char *mesg = buf;
> +	int fsid, rc;
> +
> +	if (size <= 0) return -EINVAL;
> +
> +	/* convert string into a valid fsid */
> +	rc = get_int(&mesg, &fsid);
> +	if (rc) {
> +		dprintk("nfsd: do_nlm_ip_unlock invalid ip(%s)\n", buf);
> +		return rc;
> +	}

This dprintk seems to reflect the function's previous name
and semantics.

> +
> +	/* call nlm to release the locks */
> +	rc = nlmsvc_fo_unlock(&fsid);

I don't understand why you pass this parameter by reference?
It's not large and none of the functions called by nlmsvc_fo_unlock()
need to write to it.

>  #ifdef CONFIG_NFSD_V4
> --- linux-0/include/linux/nfsd/debug.h	2006-07-14 14:32:29.000000000 -0400
> +++ linux-1/include/linux/nfsd/debug.h	2006-08-11 10:12:29.000000000 -0400
> @@ -32,6 +32,7 @@
>  #define NFSDDBG_REPCACHE	0x0080
>  #define NFSDDBG_XDR		0x0100
>  #define NFSDDBG_LOCKD		0x0200
> +#define NFSDDBG_CLUSTER 	0x0400
>  #define NFSDDBG_ALL		0x7FFF
>  #define NFSDDBG_NOCHANGE	0xFFFF
>  

You don't seem to use this anywhere.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
