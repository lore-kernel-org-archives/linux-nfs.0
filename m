From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Thu, 16 Sep 2004 21:11:54 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040917011154.GA14550@fieldses.org>
References: <1095375544.839c1c96.3@fieldses.org> <1095377931.10216.43.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C87IA-0003L2-EX
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 18:12:02 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C87I9-0004U6-Qi
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 18:12:02 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1095377931.10216.43.camel@lade.trondhjem.org>
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

On Thu, Sep 16, 2004 at 07:38:51PM -0400, Trond Myklebust wrote:
> På to , 16/09/2004 klokka 19:16, skreiv J. Bruce Fields:
> 
> > diff -L fs/nsfd/nfssvc.c -puN /dev/null /dev/null
> > diff -puN fs/lockd/svc.c~svcrpc_unix_ip_mapping_method fs/lockd/svc.c
> > --- linux-2.6.9-rc2/fs/lockd/svc.c~svcrpc_unix_ip_mapping_method	2004-09-16 16:40:53.000000000 -0400
> > +++ linux-2.6.9-rc2-bfields/fs/lockd/svc.c	2004-09-16 16:40:53.000000000 -0400
> > @@ -398,6 +398,16 @@ static int param_set_##name(const char *
> >  	return 0;							\
> >  }
> >  
> > +static int lockd_set_client(struct svc_rqst *rqstp)
> > +{
> > +	rqstp->rq_client = NULL;
> > +	if (rqstp->rq_proc == 0) /* XXX not quite right. */
> > +		return SVC_OK;
> > +	else
> > +		return svcauth_unix_set_client(rqstp);
> > +}
> > +
> 
> Is svcauth_unix_set_client() actually exported anywhere?

Nope!  Fixed, thanks.--b.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
