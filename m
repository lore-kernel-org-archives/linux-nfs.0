From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/6] nfs-utils: skip getaddrinfo in
	create_auth_rpc_client unless we need port
Date: Mon, 6 Apr 2009 11:21:06 -0400
Message-ID: <20090406112106.6b29e2b0@tleilax.poochiereds.net>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
	<1238595845-2186-4-git-send-email-jlayton@redhat.com>
	<F913F7D5-DCEE-4F40-B9C8-52DC1053A61A@oracle.com>
	<20090401134739.01b72029@barsoom.rdu.redhat.com>
	<32D01620-325D-4D82-81EF-8584134BC7DC@oracle.com>
	<20090403150415.3586bba3@tleilax.poochiereds.net>
	<194FD47F-E529-48BD-A9BC-4CA39D9A67FB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <194FD47F-E529-48BD-A9BC-4CA39D9A67FB@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 6 Apr 2009 11:03:11 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 3, 2009, at 3:04 PM, Jeff Layton wrote:
> > On Wed, 1 Apr 2009 14:01:30 -0400
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> >> As far as I understand it, the ai_socktype and ai_protocol fields are
> >> used to return the values needed for subsequent socket(2)/bind(2)
> >> system calls.  In this case you are not using these fields from the
> >> results...
> >>
> >> If ai_protocol is zero, then getaddrinfo(3) assumes you want one copy
> >> of the address for each supported protocol type, so it returns three
> >> structures (one for IPPROTO_UDP, one for IPPROTO_TCP, and one with a
> >> zero protocol number).  The contents, except for the socktype and
> >> protocol fields, are the same for each.
> >
> > Hypothetical situation...
> >
> > Suppose there is a service in /etc/services that has a different port
> > number for tcp than for udp:
> >
> > fooserv		50001/tcp
> > fooserv		50002/udp
> >
> > You're saying that getaddrinfo will return the same port number in all
> > of the returned structures? Won't that mean that one of the port  
> > numbers
> > is wrong? That seems broken if so...
> 
> I was trying to describe observed behavior here -- it's pretty  
> unlikely that there will be different port numbers in these returned  
> structures.  It's difficult to say precisely how this is supposed to  
> behave based on the man page or even browsing the glibc source code  
> for a few minutes.
> 
> It's certainly possible to set up /etc/services as you suggest, but  
> there is an IANA policy to assign the same port for both transports.   
> As near as I can tell the reason we have the transport listed in /etc/ 
> services at all is because some protocols support only one transport.   
> So IMO it would be quite unlikely to encounter such a case where the  
> port number depended on the transport.
> 
> > If that's not the case, then I think we need to at least set the
> > ai_protocol in the hints.
> 
> Perhaps that's true.  What are the expected values of @service ?
> 

I've only ever seen "nfs" here, but I guess you could use this with
others. Maybe "nfsacl" too?

IANA might not set different port like this, but there's nothing
that stops someone from doing this at their site.

I agree that it's an unlikely (and somewhat pathological) situation,
but it's easy to deal with -- just set the protocol in the hints. I've
confirmed that it makes getaddrinfo do the right thing.

-- 
Jeff Layton <jlayton@redhat.com>
