From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [Patch 4/4] Coverity #324
Date: Mon, 27 Mar 2006 11:44:04 -0800
Message-ID: <1143488644.9451.35.camel@dyn9047022153>
References: <1143485836.9451.31.camel@dyn9047022153>
	 <1143486523.28645.51.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FNxZq-0006BK-NZ
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 11:40:34 -0800
Received: from e32.co.us.ibm.com ([32.97.110.150])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FNxZp-0004TJ-HX
	for nfs@lists.sourceforge.net; Mon, 27 Mar 2006 11:40:34 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k2RJePag020762
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 14:40:25 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2RJbHUw265074
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 12:37:17 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2RJePal024999
	for <nfs@lists.sourceforge.net>; Mon, 27 Mar 2006 12:40:25 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1143486523.28645.51.camel@lade.trondhjem.org>
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

On Mon, 2006-03-27 at 14:08 -0500, Trond Myklebust wrote:
> On Mon, 2006-03-27 at 10:57 -0800, Frank Filz wrote:
> > Signed-off by: Frank Filz
> > 
> > diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
> > --- a/include/linux/nfsd/nfsfh.h
> > +++ b/include/linux/nfsd/nfsfh.h
> > @@ -328,7 +328,7 @@ fh_lock(struct svc_fh *fhp)
> >  static inline void
> >  fh_unlock(struct svc_fh *fhp)
> >  {
> > -	if (!fhp->fh_dentry)
> > +	if (!fhp || !fhp->fh_dentry)
> >  		printk(KERN_ERR "fh_unlock: fh not verified!\n");
> >  
> >  	if (fhp->fh_locked) {
> 
> Huh???
> 
> Firstly, if fhp is NULL, then fhp->fh_locked is going to Oops too.
> 
> Secondly, if fhp is NULL, then we really _ought_ to Oops in fh_unlock(),
> 'cos that would be a nasty evil coding ERROR that needs to be analysed
> and debugged.

Oops, I must have been half asleep there.

I misread the Coverity error. What it was actually complaining about was
that the code tested for NULL fh_dentry and then passed it to
fill_post_wcc, not to mention that right after the call to
fill_post_wcc, it dereferences fh_dentry.

Back to the drawing board on this one.

Frank




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
