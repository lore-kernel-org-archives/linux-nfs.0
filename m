From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Fix NFS mount options in mount.nfs
Date: Sat, 8 Jul 2006 09:31:47 +1000
Message-ID: <17582.61155.696076.339390@cse.unsw.edu.au>
References: <44AE9DC7.4050606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	sesse@debian.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fyznq-0001kH-3x
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 16:32:06 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fyznp-0003TW-Tm
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 16:32:06 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: message from Amit Gud on Friday July 7
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

On Friday July 7, agud@redhat.com wrote:
> diff -uprN -X dontdiff nfs-utils/utils/mount/Makefile.am nfs-utils-ag/utils/mount/Makefile.am
> --- nfs-utils/utils/mount/Makefile.am	2006-07-02 17:34:58.000000000 -0400
> +++ nfs-utils-ag/utils/mount/Makefile.am	2006-07-07 13:15:44.000000000 -0400
> @@ -14,9 +14,10 @@ MAINTAINERCLEANFILES = Makefile.in
>  
>  install-exec-hook:
>  	(cd $(DESTDIR)$(sbindir) && \
> -	  ln -sf $(sbin_PROGRAMS) mount.nfs4 && \
> -	  ln -sf $(sbin_PROGRAMS) umount.nfs && \
> -	  ln -sf $(sbin_PROGRAMS) umount.nfs4)
> +	  chmod +s $(sbin_PROGRAMS) && \

I do *not* have a good feeling about this... not at all.
I'm going to switch configure to default to *not* installing nfs.mount
and release 1.0.9 pretty much as-is.

We can do a proper security review and allow setuid for 1.0.10 (or
maybe it is time for 1.1.0) but I want 1.0.9 out now, and this isn't
going in. sorry.

> +/* Custom mount options for our own purposes.  */
> +/* Maybe these should now be freed for kernel use again */
> +#define MS_DUMMY	0x00000000
> +#define MS_USERS	0x40000000
> +#define MS_USER		0x20000000
> +#define MS_OWNER	0x10000000
> +#define MS_GROUP	0x08000000

OWNER and GROUP are never used, so DUMMY should just be used for
them. 

> +  { "users",    0, 0, MS_USERS  },      /* Allow ordinary user to mount */
> +  { "nousers",  0, 0, MS_USERS  },      /* Forbid ordinary user to mount */
> +  { "user",     0, 0, MS_USER   },      /* Allow ordinary user to mount */
> +  { "nouser",   0, 0, MS_USER   },      /* Forbid ordinary user to mount */

So both "users" and "nousers" set the MS_USERS flag which causes
privileged operations to be allowed?
You at least want the 'inv' flag to be set for nousers and nouser.
However that isn't enough.
The options are passed in on the command line, so anyone could give
any option they like and call /sbin/mount.nfs directly.
We can really only trust 'user' and 'users' if they are in the
/etc/fstab file, and we don't have direct access to /etc/fstab.

It would really be MUCH more secure if mount DIDN'T drop setuid, but
that isn't the case - sadly.

The only other setuid /sbin/mount.* that I have installed in
mount.cifs, and it allows anyone to mount anything on any directory
they own.  This is at least slightly safer, but I'd still rather
something more connected with /etc/fstab.....

NeilBrown

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
