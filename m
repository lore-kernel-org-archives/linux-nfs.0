From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 004 of 4] Allow max size of NFSd payload to
	be	configured.
Date: Wed, 09 Aug 2006 17:44:07 +1000
Message-ID: <1155109446.16378.126.camel@hole.melbourne.sgi.com>
References: <20060807103020.12286.patches@notabene>
	<1060807003521.12403@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAije-00056a-Jn
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 00:44:14 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAije-0008OP-Tu
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 00:44:15 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <1060807003521.12403@suse.de>
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

On Mon, 2006-08-07 at 10:35, NeilBrown wrote:
> The max possible is the maximum RPC payload.
> The default depends on amount of total memory.
>  This formula really needs to be justified.
> The value can be set within reason as long as 
>  no nfsd threads are currently running.
> 

> @@ -553,6 +556,27 @@ static ssize_t write_ports(struct file *
>  	return -EINVAL;
>  }
>  
> +int nfsd_max_blksize;
> +
> +static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
> +{
> +	char *mesg = buf;
> +	if (size > 0) {
> +		int bsize;
> +		int rv = get_int(&mesg, &bsize);
> +		if (rv)
> +			return rv;
> +		if (bsize < 1024)
> +			bsize = 1024;
> +		if (bsize > NFSSVC_MAXBLKSIZE)
> +			bsize = NFSSVC_MAXBLKSIZE;

This seems fairly unconstrained.  A sysadmin could set weird
numbers, and those numbers would then propagate to the client
via FSINFO, and possibly lead to weird bugs on a client.
How about constraining to multiples of 1024, or using KiB
as the unit?

> +		if (nfsd_serv && nfsd_serv->sv_nrthreads)
> +			return -EBUSY;
> +		nfsd_max_blksize = bsize;
> +	}

This test seems wrong to me.  In the latest code I can see,
there's only one window where nfsd_serv can be non-NULL but
nfsd_serv->sv_nrthreads == 0, and that's when the last thread
is exiting and svc_destroy() is destroying nfsd_serv.  During
that time the memory pointed to by nfsd_serv is freed and
nfsd_serv is NULLed out.  That code historically uses the BKL
for synchronisation, but here you're not taking that lock.
Also, you're not guarding against the a new nfsd_serv being
created either.

How about something like

	int err;

	lock_kernel();
	err = -EBUSY;
	if (!nfsd_serv) {
		nfsd_max_blksize = bsize;
		err = 0;
	}
	unlock_kernel();

 
> @@ -618,6 +642,7 @@ static int nfsd_fill_super(struct super_
>  		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
> +		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
>  #ifdef CONFIG_NFSD_V4

Hmm, maybe it would be a good idea to sort out the terminology
problem Chuck pointed out before exposing it to userspace.

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
