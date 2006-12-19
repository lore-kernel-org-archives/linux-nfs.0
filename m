From: Ian Kent <raven@themaw.net>
Subject: Re: [RFC:PATCH] nfs-utils - showmount RPC timeout handling
Date: Tue, 19 Dec 2006 17:55:31 +0900
Message-ID: <1166518531.3482.50.camel@raven.themaw.net>
References: <1166499757.3482.40.camel@raven.themaw.net>
	<17799.25999.584498.734073@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gwal1-0003ZJ-AT
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 00:55:34 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gwal0-0002Yq-DE
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 00:55:32 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17799.25999.584498.734073@cse.unsw.edu.au>
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

On Tue, 2006-12-19 at 15:07 +1100, Neil Brown wrote:
> On Tuesday December 19, raven@themaw.net wrote:
> > 
> > Hi all,
> > 
> > I've been doing some work on showmount to try and work out why it can
> > take a long time to return when a non-existent server is specified.
> > 
> > >From what I can see showmount itself tries to use a short timeout but
> > the RPC clnttcp_create and clntudp_create calls will call portmap
> > internally to get the port to use if it is set to 0 in the passed
> > address structure. The above calls then use the internal timeouts,
> > basically 60 seconds, which slows things down. Also the for tcp a
> > blocking connect is used which can take quite a while to timeout as
> > well.
> > 
> > showmount tries tcp then udp so a fail can go through several lengthy
> > waits before failing.
> > 
> > Another thing I noticed in showmount is that RPC procedure calls don't
> > use a call to the service null procedure before performing the call
> > itself. This is not required but can sometimes return a fail somewhat
> > more quickly than just going ahead and calling the procedure entry point
> > straight away.
> 
> I don't get this.  How can a call to NULL fail more quickly?  It
> should always succeed or timeout, and it presumably has the same
> timeout so....???

I've certainly thought the same thing but had this impression from past
experience, which may well be mistaken.

> What might make sense is to call NULL with a short time out and if
> that succeeds, call the real proceedure with a longer timeout (because
> it might take a longer time).

Think that might be a bit dangerous as if a valid response could come
back after the short timeout (which is already short for showmount) we
might abandon the request in error.

I'll get rig of the NULL calls and re-test.

> 
> > 
> > I've grabbed some of the autofs code and put together a patch to allow
> > specification of the timeouts for the portmap getport and to implement a
> > non-blocking connect.
> > 
> > I'd like feedback on the patch as to it's suitability for inclusion in
> > nfs-utils or what other work may be needed and mistakes that I may have
> > made.
> 
> Mostly good.  See below.
> 
> > 
> > Ian
> > 
> > ---
> > --- nfs-utils-1.0.8/utils/showmount/showmount.c.reduce-timeout	2005-12-20 12:12:47.000000000 +0800
> > +++ nfs-utils-1.0.8/utils/showmount/showmount.c	2006-12-15 21:35:20.000000000 +0800
> > @@ -35,6 +37,10 @@
> >  #include <mount.h>
> >  #include <unistd.h>
> >  
> > +#define TOUT_UDP	3
> > +#define TOUT_TCP	10
> > +#define TOT_TOUT	20
> > +
> 
> I guess you mean TIMEOUT_UDP TIMEOUT_TCP and TOTAL_TIMEOUT.
> Bits are cheap, and editors auto-complete.  Can we have full names
> please ??

Will do.

> 
> > +/*
> > + *  Perform a non-blocking connect on the socket fd.
> > + *
> > + *  tout contains the timeout.  It will be modified to contain the time
> > + *  remaining (i.e. time provided - time elasped).
> > + */
> > +static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval *tout)
> > +{
> > +	int flags, ret;
> > +	socklen_t len;
> > +	fd_set wset, rset;
> ....
> > +
> > +	/* now wait */
> > +	FD_ZERO(&rset);
> > +	FD_SET(fd, &rset);
> > +	wset = rset;
> > +
> > +	ret = select(fd + 1, &rset, &wset, NULL, tout);
> 
> Do we need wset as well as rset?  I thought a connection socket would
> always signal in rset, so wset is redundant.  I'm will to be educated
> though.

Haven't really thought about it.
I'll check and amend as needed.

> 
> > +
> > +static unsigned short getport(struct sockaddr_in *addr,
> > +			 unsigned long prog, unsigned long vers, int prot)
> > +{
> ....
> > +
> > +		laddr.sin_family = AF_INET;
> > +		laddr.sin_port = 0;
> > +		laddr.sin_addr.s_addr = htonl(INADDR_ANY);
> > +
> > +		tout.tv_sec = TOUT_UDP;
> > +
> > +		send_sz = RPCSMALLMSGSIZE;
> > +		recv_sz = RPCSMALLMSGSIZE;
> > +
> > +		len = sizeof(struct sockaddr_in);
> > +		if (bind(sock, (struct sockaddr *)&laddr, len) < 0) {
> 
> Isn't this bind a no-op?  When you first write to a socket which is
> unbound it is automatically bound, so you don't need to pre-bind it.

Possibly, but personally I like to retain stuff like this for internal
documentation.

Do you feel strongly about it?

Thanks
Ian



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
