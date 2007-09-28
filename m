From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 33/33] knfsd: Support adding transports by writing	portlist
	file
Date: Fri, 28 Sep 2007 12:33:58 -0500
Message-ID: <1191000838.10604.97.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050243.12677.15463.stgit@dell3.ogc.int>
	<18172.34744.784138.666846@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbJk9-00049U-QY
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 10:35:13 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbJkE-0000Mf-IX
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 10:35:18 -0700
In-Reply-To: <18172.34744.784138.666846@notabene.brown>
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

On Fri, 2007-09-28 at 14:48 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > 
> > Update the write handler for the portlist file to allow creating new
> > listening endpoints on a transport. The general form of the string is:
> > 
> > <transport_name><space><port number>
> > 
> > For example:
> > 
> > tcp 2049
> > 
> > This is intended to support the creation of a listening endpoint for
> > RDMA transports without adding #ifdef code to the nfssvc.c file.
> > The general idea is that the rpc.nfsd program would read the transports
> > file and then write the portlist file to create listening endpoints
> > for all or selected transports. The current mechanism of writing an
> > fd would become obsolete.
> 
> Nuh.
> I'll only accept
>       rdma 2049
> (or whatever) because there seems to be no other way to do it.
> Writing an 'fd' is the *preferred* way.
> 
> There is more to binding an endpoint than protocol and port number.
> There is also local address and I'm not convinced that someone might
> come up with some other way they want to pre-condition a socket.

Agreed. 

Forgive me for deferring the it-should-be-socket question for a
paragraph or two, but...

This version was much less ambitious than what I wanted to do, which was
extend the syntax and consolidate listener creation.

The string would be something like:

addr-qualifier addr port xprt-string xprt-specific-ops

For example,
ipv4 0.0.0.0 2049 udp
ipv4 10.2.1.5 2049 tcp
ipv6 ff:ff:ff:ff:10.4.1.5 2049 tcp
ipv4 10.3.1.5 2050 rdma 

The upside is that all listeners would be created in the same way. The
downside is that the string processing and endpoint creation are all
done in the kernel in the proc-fs handler.

> If there was any way to associate an RDMA endpoint with a
> filedescriptor, I would much prefer that 'rpc.nfsd' does that and passes
> down the filedescriptor.  

With regard to associating a socket with an RDMA endpoint, IMO it is
technically feasible, but politically impossible at this point. Various
degrees of integration have been discussed on both the OpenFabrics and
netdev mailing lists. To summarize the viewpoints:

- Key "netdev/core people" do not want _any_ core changes to enable RDMA
under any circumstances. They believe iWARP(RDMA/TOE) and IB (RDMA) are
"point in time technologies" that are doomed to the bone pile and that
integrating into the core would complicate and destabilize the stack.

- Most "RDMA people" see no benefit in sockets because the I/O model is
so different, the sockets connection model is not asynchronous, and
there is no way to specify the RDMA transport connection and route
qualifiers.

- A few "RDMA people" like a sockets approach. It was actually
implemented as part of an early SDP IB implementation. 

Obviously, there are as many variants of the above as there are dogs in
the fight, but this is my sense of the fundamental issues.

> If RDMA is so no-Unix-like (rant rant..) 
> that there is no such file descriptor, then I guess we can live with 
> getting the kernel to open the connection.
> 

At this point, I believe this is the way to do it. 

Thanks,

Tom
> 
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  fs/nfsd/nfsctl.c |   16 ++++++++++++++++
> >  1 files changed, 16 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index baac89d..923b817 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -554,6 +554,22 @@ static ssize_t write_ports(struct file *
> >  		kfree(toclose);
> >  		return len;
> >  	}
> > +	/*
> > +	 * Add a transport listener by writing it's transport name
> > +	 */
> > +	if (isalnum(buf[0])) {
> 
> Should really be "isalpha" as we already know it isn't isdigit.
> 
> NeilBrown
> 
> 
> > +		int err;
> > +		char transport[16];
> > +		int port;
> > +		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
> > +			err = nfsd_create_serv();
> > +			if (!err)
> > +				err = svc_create_xprt(nfsd_serv,
> > +						      transport, port,
> > +						      SVC_SOCK_ANONYMOUS);
> > +			return err < 0 ? err : 0;
> > +		}
> > +	}
> >  	return -EINVAL;
> >  }
> >  


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
