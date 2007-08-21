From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC, PATCH 06/20] svc: export	svc_sock_enqueue,
	svc_sock_received
Date: Tue, 21 Aug 2007 13:08:48 -0500
Message-ID: <1187719728.26221.61.camel@trinity.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162334.15224.17433.stgit@dell3.ogc.int>
	<46CB0CC3.8080102@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INYBa-0001CM-Ql
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 11:10:38 -0700
Received: from ms-smtp-02.texas.rr.com ([24.93.47.41])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INYBe-0004zr-VP
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 11:10:43 -0700
In-Reply-To: <46CB0CC3.8080102@oracle.com>
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

Good point. 

Actually, there are a number of interfaces like this. I guess we could
move the generic transport interfaces to svc_xprt.c. Then svcsock.c
would contain the tcp/udp transport driver.

On Tue, 2007-08-21 at 12:03 -0400, Chuck Lever wrote:
> Tom Tucker wrote:
> > Export svc_sock_enqueue() and svc_sock_received() so they
> > can be used by sunrpc server transport implementations
> > (even future modular ones).
> > 
> > Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> > Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  include/linux/sunrpc/svcsock.h |    2 ++
> >  net/sunrpc/svcsock.c           |    7 ++++---
> >  2 files changed, 6 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> > index 4e24e6d..0145057 100644
> > --- a/include/linux/sunrpc/svcsock.h
> > +++ b/include/linux/sunrpc/svcsock.h
> > @@ -108,6 +108,8 @@ int		svc_addsock(struct svc_serv *serv,
> >  			    int fd,
> >  			    char *name_return,
> >  			    int *proto);
> > +void		svc_sock_enqueue(struct svc_sock *svsk);
> > +void		svc_sock_received(struct svc_sock *svsk);
> 
> If these aren't socket-specific, then I would rename them, and move them 
> to a generic source file instead of keeping them in svcsock.c and svcsock.h.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
