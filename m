From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH] fix recursive nlm_file_mutex deadlock
Date: Wed, 09 Aug 2006 14:32:36 -0400
Message-ID: <44DA2A44.1060001@redhat.com>
References: <44DA25D3.3010003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAssB-0004nA-2S
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 11:33:43 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAssB-00085B-CI
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 11:33:43 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k79IXaG4030417
	for <nfs@lists.sourceforge.net>; Wed, 9 Aug 2006 14:33:36 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k79IXaYd028336
	for <nfs@lists.sourceforge.net>; Wed, 9 Aug 2006 14:33:36 -0400
Received: from [172.16.59.28]
	(IDENT:U2FsdGVkX1/305Tk4gH91X7d1ftADxJQVZhhKHgjStA@wendyc.rdu.redhat.com
	[172.16.59.28])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	k79IXa6t012143
	for <nfs@lists.sourceforge.net>; Wed, 9 Aug 2006 14:33:36 -0400
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: <44DA25D3.3010003@redhat.com>
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

Wendy Cheng wrote:

>
> The attached patch seems to fix the issue - it skips (defers) the file 
> removal. Eventually either nlm_gc_hosts (some time later when client 
> is unmonitored) or nlmsvc_traverse_files will finish the clean up.  
> Note that this is a 10-minutes  work - not sure its ramification at 
> this moment. Take a look ?
>
Well, I never really understand what this "signed-off" line is all 
about. But if it is required, here it is:

Signed-off-by: S. Wendy Cheng (wcheng@redhat.com)


>
>------------------------------------------------------------------------
>
>--- linux-2/fs/lockd/svclock.c	2006-08-08 10:20:16.000000000 -0400
>+++ linux/fs/lockd/svclock.c	2006-08-09 10:28:35.000000000 -0400
>@@ -264,7 +264,9 @@ static void nlmsvc_free_block(struct kre
> 
> 	nlmsvc_freegrantargs(block->b_call);
> 	nlm_release_call(block->b_call);
>-	nlm_release_file(block->b_file);
>+	down(&file->f_sema);
>+	file->f_count--;
>+	up(&file->f_sema);
> 	kfree(block);
> }
> 
>  
>

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
