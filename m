From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: Re: NFSv3 blocking locks broken in 2.6.7
Date: Wed, 18 Aug 2004 17:44:48 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF5D98042A.0F02E0AD-ON88256EF5.0003D053-88256EF5.00041A3D@us.ibm.com>
References: <1092872360.9329.106.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1092872360.9329.106.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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





Thanks for the quick response, this patch fixed the problem.
Marc.

nfs-admin@lists.sourceforge.net wrote on 08/18/2004 04:39:20 PM:

> P=E5 on , 18/08/2004 klokka 17:30, skreiv Marc Eshel:
> >
> >
> > Hi Trond,
> >
> > I tried the changed that you recommended on the NFS client but it d=
id
not
> > help. Following is an NLM trace on the NFS server that shows the
problem.
> > Tracing the code points to a problem that is marked below with '***=
**'
> >

> Well debugged!

> Grr... These "design cleanups" are costing a lot of extra work to fix=
 up
> the bugs.

> So the following patch fixes it for you then?

> Cheers,
> Trond
> --- linux-2.6.8.1-grrr/fs/lockd/svclock.c.orig 2004-08-14 14:25:56.
> 000000000 -0400
> +++ linux-2.6.8.1-grrr/fs/lockd/svclock.c 2004-08-18 19:34:13.0000000=
00
-0400
> @@ -238,8 +238,13 @@ nlmsvc_delete_block(struct nlm_block *bl

> /* Remove block from list */
> nlmsvc_remove_block(block);
> - posix_unblock_lock(&file->f_file, fl);
> - block->b_granted =3D 0;
> + if (fl->fl_next)
> +  posix_unblock_lock(&file->f_file, fl);
> + if (unlock) {
> +  fl->fl_type =3D F_UNLCK;
> +  posix_lock_file(&file->f_file, fl);
> +  block->b_granted =3D 0;
> + }

> /* If the block is in the middle of a GRANT callback,
> * don't kill it yet. */=




-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
