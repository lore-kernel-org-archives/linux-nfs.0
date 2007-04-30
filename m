From: Neil Brown <neilb@suse.de>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Tue, 1 May 2007 07:19:44 +1000
Message-ID: <17974.23920.40070.101936@notabene.brown>
References: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Kottaridis, Chris" <chris.kottaridis@windriver.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HidI2-0003sR-R4
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 14:20:10 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HidI3-00040V-Da
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 14:20:13 -0700
In-Reply-To: message from Kottaridis, Chris on Monday April 30
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

On Monday April 30, chris.kottaridis@windriver.com wrote:
> I have a situation where rpc.mountd is growing continuously and I am not
> sure if it's a memory leak or expected behavior that can be controlled
> with some configuration option.
>  
...
>  
> I am using the kernel NFSD, the kernel version is 2.6.10, the nfs-utils
> version is nfs-utils-1.0.7

Can you try this patch - unless you are using rpcsec/gss, it is the
only known leak likely to affect that version.

If that doesn't help you might need to try valgrind or similar.

NeilBrown


commit 08964495c2a65f6228426e4565a50dae5b75834d
Author: Steinar H. Gunderson <sgunderson@bigfoot.com>
Date:   Fri Mar 16 11:26:35 2007 +1100

    Fix memory leak in mountd.
    
    Signed-off-by: Neil Brown <neilb@suse.de>

diff --git a/support/export/client.c b/support/export/client.c
index 33dfdb0..686c744 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -329,6 +329,7 @@ add_name(char *old, char *add)
 		strcat(new, ",");
 		strcat(new, cp);
 	}
+	free(old);
 	return new;
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
