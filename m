From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Support for NFSv4 READ + WRITE attribute cache consistency
Date: Fri, 20 Dec 2002 23:02:56 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0212202300440.3439-100000@home.transmeta.com>
References: <15871.27115.53994.646430@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from neon-gw-l3.transmeta.com ([63.209.4.196] helo=neon-gw.transmeta.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18PdeP-0001Yv-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Dec 2002 23:02:21 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15871.27115.53994.646430@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


I _really_ don't like crud like this.

NFS v4 is still not exactly common, but this change makes the kernel
uncompilable if you have one of the common NFS clients but didn't enable
NFS_V4 - those fields are used unconditionally, but they are only defined
conditionally.

Please don't do this, and please _do_ test with "normal" configurations.

		Linus

On Tue, 17 Dec 2002, Trond Myklebust wrote:
> diff -u --recursive --new-file linux-2.5.52-02-nfsv4_write/include/linux/nfs_xdr.h linux-2.5.52-03-nfsv4_attr/include/linux/nfs_xdr.h
> --- linux-2.5.52-02-nfsv4_write/include/linux/nfs_xdr.h	2002-12-17 15:27:47.000000000 +0100
> +++ linux-2.5.52-03-nfsv4_attr/include/linux/nfs_xdr.h	2002-12-17 15:28:07.000000000 +0100
> @@ -35,8 +35,11 @@
>  	struct timespec		atime;
>  	struct timespec		mtime;
>  	struct timespec		ctime;
> +#ifdef CONFIG_NFS_V4
> +	__u32			bitmap[2];	/* NFSv4 returned attribute bitmap */
>  	__u64			change_attr;	/* NFSv4 change attribute */
>  	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
> +#endif
>  	unsigned long		timestamp;
>  };
>
>
>
>



-------------------------------------------------------
This SF.NET email is sponsored by:  The Best Geek Holiday Gifts!
Time is running out!  Thinkgeek.com has the coolest gifts for
your favorite geek.   Let your fingers do the typing.   Visit Now.
T H I N K G E E K . C O M        http://www.thinkgeek.com/sf/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
