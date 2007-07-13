From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 015 of 20] knfsd: nfsd4: make readonly access
 depend on pseudoflavor
Date: Fri, 13 Jul 2007 00:12:15 -0700
Message-ID: <20070713001215.b4b57a5b.akpm@linux-foundation.org>
References: <20070710121949.12548.patches@notabene>
	<1070710022749.13539@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9FKF-000759-6L
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 00:12:29 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9FKH-0001zl-Mg
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 00:12:30 -0700
In-Reply-To: <1070710022749.13539@suse.de>
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

On Tue, 10 Jul 2007 12:27:49 +1000 NeilBrown <neilb@suse.de> wrote:

> 
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Allow readonly access to vary depending on the pseudoflavor, using the
> flag passed with each pseudoflavor in the export downcall.
> 
> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./include/linux/nfsd/export.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
> --- .prev/include/linux/nfsd/export.h	2007-07-10 11:40:31.000000000 +1000
> +++ ./include/linux/nfsd/export.h	2007-07-10 11:50:43.000000000 +1000
> @@ -43,7 +43,7 @@
>  #define NFSEXP_ALLFLAGS		0xFE3F
>  
>  /* The flags that may vary depending on security flavor: */
> -#define NFSEXP_SECINFO_FLAGS	0
> +#define NFSEXP_SECINFO_FLAGS	NFSEXP_READONLY
>  
>  #ifdef __KERNEL__
>  

You have two patches called "knfsd: nfsd4: make readonly access depend on
pseudoflavor".  This one appears to have the wrong title and changelog.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
