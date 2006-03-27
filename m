From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Patch 4/4] Coverity #324
Date: Mon, 27 Mar 2006 14:08:43 -0500
Message-ID: <1143486523.28645.51.camel@lade.trondhjem.org>
References: <1143485836.9451.31.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FNx5U-0002ik-Eg
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 11:09:12 -0800
Received: from pat.uio.no ([129.240.10.6])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FNx5S-0000cK-VG
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 11:09:12 -0800
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: <1143485836.9451.31.camel@dyn9047022153>
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

On Mon, 2006-03-27 at 10:57 -0800, Frank Filz wrote:
> Signed-off by: Frank Filz
> 
> diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
> --- a/include/linux/nfsd/nfsfh.h
> +++ b/include/linux/nfsd/nfsfh.h
> @@ -328,7 +328,7 @@ fh_lock(struct svc_fh *fhp)
>  static inline void
>  fh_unlock(struct svc_fh *fhp)
>  {
> -	if (!fhp->fh_dentry)
> +	if (!fhp || !fhp->fh_dentry)
>  		printk(KERN_ERR "fh_unlock: fh not verified!\n");
>  
>  	if (fhp->fh_locked) {

Huh???

Firstly, if fhp is NULL, then fhp->fh_locked is going to Oops too.

Secondly, if fhp is NULL, then we really _ought_ to Oops in fh_unlock(),
'cos that would be a nasty evil coding ERROR that needs to be analysed
and debugged.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
