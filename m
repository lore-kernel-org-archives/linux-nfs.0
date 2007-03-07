From: AK <amithl_prem@yahoo.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Wed, 7 Mar 2007 13:32:57 -0800 (PST)
Message-ID: <141076.2067.qm@web56606.mail.re3.yahoo.com>
References: <45EEFCA4.40000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP3kv-000826-A1
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:33:06 -0800
Received: from web56606.mail.re3.yahoo.com ([66.196.97.50])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HP3kt-0006Sy-3m
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:33:07 -0800
In-Reply-To: <45EEFCA4.40000@redhat.com>
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


--- Peter Staubach <staubach@redhat.com> wrote:

> > We have multiple file systems begin mounted from
> the
> > same NFS server. One of our user's application
> > requires to mount the file system with 'noac'
> option. 
> >
> >   
> 
> What about this application requires that the "noac"
> option be used?
  application is romio with mpich2 ...
 
> 
> One of the impacts of using the "noac" option is
> much more network
> traffic and it will be composed of small packets. 
> If the server is
> busy handling all of the additional GETATTR
> requests, then it won't
> be handling other requests.  The client will also be
> a bit busier
> with generating the additional requests, instead of
> just doing what
> might be considered more useful work.
> 
> So, there should be no direct impact to other
> mounted file systems.
> However, there may be indirect impacts.

indirect impacts: can you please elaborate on this.

~ thanks!


 
____________________________________________________________________________________
It's here! Your new message!  
Get new email alerts with the free Yahoo! Toolbar.
http://tools.search.yahoo.com/toolbar/features/mail/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
