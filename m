From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 05/12] SUNRPC: Add a function to format the
	address in an svc_rqst for printing
Date: Fri, 10 Nov 2006 16:44:46 +1100
Message-ID: <17748.4558.178432.858323@cse.unsw.edu.au>
References: <20061101180830.14581.18323.stgit@schiele.dsl.sfldmi.ameritech.net>
	<17746.42034.768127.846582@cse.unsw.edu.au>
	<20061109101638.GB24104@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GiPC0-000576-MX
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 21:44:44 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GiPC0-0002PI-Ki
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 21:44:46 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Thursday November 9
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

On Thursday November 9, okir@suse.de wrote:
> On Thu, Nov 09, 2006 at 02:44:50PM +1100, Neil Brown wrote:
> > > +void svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
> > > +{
> > > +	__svc_print_addr((struct sockaddr *) &rqstp->rq_addr, buf, len);
> > > +
> > > +}
> > 
> > Can we have svc_print_addr take a 
> >   char buf[RPC_MAX_ADDRBUFLEN]
> > rather than a char* and a len?  The buffer is always the same size, so
> > best to hard code it..
> 
> The compiler will still let you pass a buf[6] without complaining.
> Assumptions that buffer arguments are "big enough" make for great
> security bugs two years down the road because people forget.
> There's a reason why getwd and gets have been deprecated for 18 years :)

I had hoped that sparse would pick it up, but it seems now.

> 
> If you want to make it easy, why not have
> 
> #define RPC_SVC_ADDR(rqstp, buf) \
> 	(svc_print_addr(rqstp, buf, sizeof(buf)))

That's one option.
Another would be

  struct rpc_addr { char buf[RPC_MAX_ADDRBUFLEN]; };

  char *svc_print_addr(struct svc_rqst rqstp, struct rpc_addr *buf)
  {
       ....
       return buf->buf;
  }

so we force the compiler to check the allocated space.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
