From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 03/17] mount.nfs: Remove support for "-t" option
Date: Mon, 16 Jul 2007 13:37:42 +1000
Message-ID: <18074.59398.729707.566494@notabene.brown>
References: <20070716031503.11209.67390.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAHP4-00049G-EL
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:37:42 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAHP5-0002iA-De
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:37:46 -0700
In-Reply-To: message from Chuck Lever on Sunday July 15
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sunday July 15, chuck.lever@oracle.com wrote:
> /bin/mount will never pass "-t" to a mount helper, since it passes the
> fs-type in the name of the program it is executing.

Does it hurt to leave it there though?  Maybe it makes unit-testing
easier?
Or maybe not....

> @@ -413,23 +413,12 @@ int main(int argc, char *argv[])
>  	mount_point = argv[2];
>  
>  	argv[2] = argv[0]; /* so that getopt error messages are correct */
> -	while ((c = getopt_long (argc - 2, argv + 2, "rt:vVwfno:hs",
> +	while ((c = getopt_long (argc - 2, argv + 2, "r:vVwfno:hs",
                                                      ^^

Ooops.  -r takes an argument now?

>  		if ((mc = getfsfile(mount_point)) == NULL ||
> -		    strcmp(mc->m.mnt_fsname, spec) != 0 ||
> -		    strcmp(mc->m.mnt_type, (nfs_mount_vers == 4 ? "nfs4":"nfs")) != 0
> -		    ) {
> -			fprintf(stderr, "%s: permission died - no match for fstab\n",
> -				progname);
> +		    !strcmp(mc->m.mnt_fsname, spec) ||
                   ^^^^

I absolutely LOATHE that construct. The first thing you read is "!"
which means "not" but it is actually a test for "are these things
equal" which makes it confusing (to me).  So I always like to see the
result of strcmp tested with "== 0"  "< 0"  "> 0"  as the relation
given applies exactly to the tested relation between the strings.

Further:
> -		    strcmp(mc->m.mnt_fsname, spec) != 0 ||
and
> +		    !strcmp(mc->m.mnt_fsname, spec) ||

are opposite tests, and it is not clear to me why you inverted the
test.

> @@ -533,7 +525,7 @@ int main(int argc, char *argv[])
>  	if (chk_mountpoint(mount_point))
>  		exit(EX_FAIL);
>  
> -	if (nfs_mount_vers == 4)
> +	if (!strcmp(fs_type, "nfs4"))
            ^
There it is again... HATE HATE HATE HATE .....
It makes me think 'If the fs_type is not "nfs4"' which is not what is
going on at all.

But otherwise there are some fairly useful clean-ups in there.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
