From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] Timeouts gone wild on ia64
Date: Thu, 15 May 2003 08:34:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61131274C6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GKkw-0005Wo-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 08:34:54 -0700
To: "Steve Dickson" <SteveD@redhat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> >you want to keep the retransmit timeout as short as possible,
> >just before things start timing out.  this means you get the fastest
> >possible recovery when the server drops a request. =20
> >
> That's assuming server drops the request... now if the server is
> simply buzy because its severing hundreds of clients and it
> takes 6ms to respond, you now have hundreds of clients retransmitting
> very 4ms (for basically for no reason) which is just adding to the=20
> problem...
> I'm sure the RTO code would eventually increase the timeout which
> would smooth everything out but before that happens you would be
> blasting the network with a ton of unnecessary retransmits... True?

we're agreeing vehemently.  the RTO estimator should
*start* at a larger timeout value to prevent this.

> >but what i'm hearing is the starting RTO is probably not
> >optimal for slow servers.  right now the initial value is:
> >=20
> >  #define RPC_RTO_INIT (HZ/5)
> >=20
> >(200ms) which is perhaps too small.  a better value for
> >general use might be HZ/2 (half a second).  then the
> >estimator can adjust downward for faster servers while
> >behaving practically for slow ones.

i agree with trond that fixing mount is a good idea...
however, the mount command's initial RTO value is up
in the hundreds of msec.  so why does the estimator
allow the RTO values to drop for slow servers?

the default retransmit count is too low for UDP.  but
i think we all agree on that.

> By increasing the initial timeout, ISTM, that the client
> is assuming a slower server verses a fast one... which will
> probably work as well... Its just that I thought making
> all of the RTO constants value relative to HZ was a good idea...

yes, making the RTO constants relative to HZ is a good
idea.  i think the objection is to raising the minimum
RTO at the same time.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
