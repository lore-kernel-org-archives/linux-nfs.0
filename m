From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 004 of 4] Allow max size of NFSd payload to
	be	configured.
Date: Mon, 14 Aug 2006 16:31:59 +1000
Message-ID: <17632.6367.44274.283418@cse.unsw.edu.au>
References: <20060807103020.12286.patches@notabene>
	<1060807003521.12403@suse.de>
	<1155109446.16378.126.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCVzc-000195-3z
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 23:32:08 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCVzc-0005A9-6Y
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 23:32:08 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Wednesday August 9
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

On Wednesday August 9, gnb@melbourne.sgi.com wrote:
> On Mon, 2006-08-07 at 10:35, NeilBrown wrote:
> >  
> > +int nfsd_max_blksize;
> > +
> > +static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
> > +{
> > +	char *mesg = buf;
> > +	if (size > 0) {
> > +		int bsize;
> > +		int rv = get_int(&mesg, &bsize);
> > +		if (rv)
> > +			return rv;
> > +		if (bsize < 1024)
> > +			bsize = 1024;
> > +		if (bsize > NFSSVC_MAXBLKSIZE)
> > +			bsize = NFSSVC_MAXBLKSIZE;
> 
> This seems fairly unconstrained.  A sysadmin could set weird
> numbers, and those numbers would then propagate to the client
> via FSINFO, and possibly lead to weird bugs on a client.
> How about constraining to multiples of 1024, or using KiB
> as the unit?

Good point.  I like to avoid magic units, so I'll round it down to a
multiple of 1024.

> 
> > +		if (nfsd_serv && nfsd_serv->sv_nrthreads)
> > +			return -EBUSY;
> > +		nfsd_max_blksize = bsize;
> > +	}
> 
> This test seems wrong to me.  In the latest code I can see,
> there's only one window where nfsd_serv can be non-NULL but
> nfsd_serv->sv_nrthreads == 0, and that's when the last thread
> is exiting and svc_destroy() is destroying nfsd_serv.  During
> that time the memory pointed to by nfsd_serv is freed and
> nfsd_serv is NULLed out.  That code historically uses the BKL
> for synchronisation, but here you're not taking that lock.
> Also, you're not guarding against the a new nfsd_serv being
> created either.

You are right about the need for BKL - thanks.

There is another window.
Write_ports creates the nfsd_serv to attach sockets, but doesn't
attach any threads.  So we have to allow for that.

> 
> Hmm, maybe it would be a good idea to sort out the terminology
> problem Chuck pointed out before exposing it to userspace.

There's certainly sense in that... I'll go reply to the Email next.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
