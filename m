From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 000 of 4] knfsd: Introduction
Date: Thu, 3 Aug 2006 11:22:23 +1000
Message-ID: <17617.20431.425742.221648@cse.unsw.edu.au>
References: <20060728150606.29533.patches@notabene>
	<20060728211000.GA19563@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8Rv3-00026a-OG
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 18:22:37 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8Rv3-0007jb-Nx
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 18:22:38 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Friday July 28
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

On Friday July 28, bfields@fieldses.org wrote:
> On Fri, Jul 28, 2006 at 03:09:40PM +1000, NeilBrown wrote:
> > Following are 4 patches for knfsd in 2.6-mm-latest.  They address some
> > issues found by Bruce Fields greatly appreciated patch review.  Thanks Bruce.
> > They (like the patches they build on) are *not* 2.6.18 material.
> 
> By the way, the one thing that looked to me like a real bug was the
> failure to do a lockd_down() when the user deletes a socket (comments
> resent below), which these patches don't seem to deal with.  Of course,
> it's entirely possible I just didn't understand something....
> 

Ofcourse, it is also entirely possible that you understand perfectly,
and that seems to be the case here.  If the svc_sock_names call in
write_ports returns success, we should do a 'lockd_down' - and make
sure it does return success only if the close succeeded.


> --b.
> 
> 
> On Tue, Jul 25, 2006 at 11:55:08AM +1000, NeilBrown wrote:
> > +		err = nfsd_create_serv();
> > +		if (!err) {
> > +			int proto = 0;
> > +			err = svc_addsock(nfsd_serv, fd, buf, &proto);
> > +			/* Decrease the count, but don't shutdown the
> > +			 * the service
> > +			 */
> > +			if (err >= 0)
> > +				lockd_up(proto);
> > +			nfsd_serv->sv_nrthreads--;
> ....
> > @@ -211,8 +211,6 @@ static inline int nfsd_create_serv(void)
> >  			       nfsd_last_thread);
> >  	if (nfsd_serv == NULL)
> >  		err = -ENOMEM;
> > -	else
> > -		nfsd_serv->sv_nrthreads++;
> 
> I don't understand these sv_nrthreads changes.
> 

The first is simply to counter the reference that was gained in
nfsd_create_serv. 

The second chunk (removing sv_nrthread++) is fixing a bug in an
earlier patch.  We never should have had that ++ there, as
'svc_create' created the object with a reference already.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
