From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: Re: [NFS][PATCH] Making sure negative lookup entries don't exist
Date: Fri, 28 Jan 2005 20:08:08 -0500
Message-ID: <41FAE1F8.3040307@sun.com>
References: <41FA88D5.6010904@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cuh6G-0002oj-Lu
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 17:08:32 -0800
Received: from brmea-mail-3.sun.com ([192.18.98.34])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cuh6G-0006FT-5G
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 17:08:32 -0800
Received: from phys-mpk-1 ([129.146.11.81])
	by brmea-mail-3.sun.com (8.12.10/8.12.9) with ESMTP id j0T18VVu010523
	for <nfs@lists.sourceforge.net>; Fri, 28 Jan 2005 18:08:31 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0IB200M010A6WF@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Fri, 28 Jan 2005 17:08:31 -0800 (PST)
In-reply-to: <41FA88D5.6010904@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Steve Dickson wrote:
> Here is a 2.4.28 patch that ensures negative cached dirents
> do not exist by always doing an otw getattr to the server.
> This does cause a small increase in getattrs (~3% from what
> I saw in my testing) but it seems to me the price is worth it to
> ensure the client does not lie about the existence of a file.
> 
> comments?
> 
> steved.
> 
> 
> ------------------------------------------------------------------------
> 
> --- linux-2.4.28/fs/nfs/dir.c.orig	2004-08-07 19:26:06.000000000 -0400
> +++ linux-2.4.28/fs/nfs/dir.c	2005-01-28 13:00:59.402239000 -0500
> @@ -455,7 +455,11 @@ int nfs_lookup_verify_inode(struct inode
>   */
>  static inline int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry)
>  {
> -	if (!nfs_check_verifier(dir, dentry))
> +	if (IS_ROOT(dentry))
> +		return 1;

I don't think this is needed.  Aren't you guaranteed that a root dentry
will never have ->d_revalidate called?

> +	if (__nfs_revalidate_inode(NFS_SERVER(dir), dir))
> +		return 1;
> +	if (time_after(NFS_MTIME_UPDATE(dir), dentry->d_time))
>  		return 1;
>  	return time_after(jiffies, dentry->d_time + NFS_ATTRTIMEO(dir));
>  }

Am I missing something? or doesn't nfs_check_verifier do exactly these
checks already?

- --
Mike Waychison
Sun Microsystems, Inc.
1 (650) 352-5299 voice
1 (416) 202-8336 voice

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NOTICE:  The opinions expressed in this email are held by me,
and may not represent the views of Sun Microsystems, Inc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFB+uH3dQs4kOxk3/MRArnXAJsGRs/yb8fazMcgB/T1l5K+o0O3qQCfXBEg
+C712kBY6Nhp78X1qelIwe4=
=AAyH
-----END PGP SIGNATURE-----


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
