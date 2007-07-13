From: walt <wa1ter@myrealbox.com>
Subject: Re: nfsd oops in current -git
Date: Fri, 13 Jul 2007 12:18:19 -0700
Message-ID: <f78j5t$ttc$1@sea.gmane.org>
References: <469780BB.3070206@trash.net>
	<4697A7EC.6050006@redhat.com>	<20070713163337.GT5328@kernel.dk>
	<20070713165001.GV5328@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9Qeq-0002FW-4m
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 12:18:28 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9Qet-00079R-HB
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 12:18:31 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I9Qep-0000qg-1z
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 21:18:27 +0200
Received: from adsl-69-234-179-158.dsl.irvnca.pacbell.net ([69.234.179.158])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jul 2007 21:18:27 +0200
Received: from wa1ter by adsl-69-234-179-158.dsl.irvnca.pacbell.net with local
	(Gmexim 0.1 (Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jul 2007 21:18:27 +0200
In-Reply-To: <20070713165001.GV5328@kernel.dk>
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

Jens Axboe wrote:

>>> On 07/13/2007 09:40 AM, Patrick McHardy wrote:
>>>> I get this oops with current -git:
...
> Patrick, does this work?
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 8604e35..945b1ce 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -879,6 +879,7 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  			.u.data		= rqstp,
>  		};
>  
> +		rqstp->rq_resused = 1;
>  		host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
>  	} else {
>  		oldfs = get_fs();
> 

Hi Jens,

I'm not Patrick, but this patch fixes the nfsd problem I posted about
in the webservers-stopped-working thread earlier today.  Many thanks.



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
