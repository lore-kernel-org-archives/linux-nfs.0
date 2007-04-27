From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 27 Apr 2007 08:20:17 +0200
Message-ID: <200704270820.19718.olaf.kirch@oracle.com>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251056.03664.olaf.kirch@oracle.com>
	<46312615.2090307@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhJqi-0000WI-Rt
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 23:22:32 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhJql-00028R-29
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 23:22:35 -0700
In-Reply-To: <46312615.2090307@RedHat.com>
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

On Friday 27 April 2007 00:22, Steve Dickson wrote:
> So the glibc can indeed allocate memory a ton of gids
> but then only sends NGRPS of them... which is a complete
> waste of memory and time...  imho..

No. If you don't do this, you will not get *any* gids.
getgroups simply fails if the array you give it is too short.
And tirpc deals with that rather ungracefully by calling
abort(), of all things.

> Well since gethostbyname_r() is a GNU extension it understandable
> why its not in the BSD based code... Also in tirpc, gethostbyname()
> routine is *not* used in the highly used  clnt_create() call as
> its is in glibc . In tirpc the routine getaddrinfo() is used to
> resolve host names in clnt_create() and I don't think there is a
> thread safe version of that...

getaddrinfo is thread-safe, so that is fine.

> Also the only two place gethostbyname() is used in tirpc is in
> getrpcport() and in the a few calls down from authdes_refresh().
> 
> Now there are calls to mutex_lock/unlock so in the end there
> multithread support... at least in that part of the code...

Ah, okay.

> >  -	it seems that tirpc unconditionally requires rpcbind,
> > 	even for applications that still use pmap_set and
> > 	friends. In the interest of a smooth transition, applications
> > 	using the old interface should be able to expect the
> > 	old behavior.
> I not understanding your point... all the pmap_xxx routine are
> supported, taking the same arguments and return same value.
> Internally they definitely do things differently, which should
> not be a problem...so where are you seeing the potential
> transition problems?

It means you cannot run a binary linked against tirpc
on a host that runs portmap but no rpcbind. E.g.
pmap_set will simply fail if it can't connect to
rpcbind via AF_LOCAL. I think any replacement for
libc's sunrpc code should continue to work in a
portmap environment.

> >  -	tirpc does truly bizarre things, eg in clnt_raw.c
> > 	it declares a local variable, and then acquires
> > 	a mutex to check this local variable for NULL:
> > 
> > 	       mutex_lock(&clntraw_lock);
> > 	       if (clp == NULL) {
> > 	               mutex_unlock(&clntraw_lock);
> > 	               return (RPC_FAILED);
> > 	       }
> > 	       mutex_unlock(&clntraw_lock);
> Look again... clp is pointing to global data... so locks
> are needed...

Yes, clp is *pointing* at global data, so the data it
points at may change. But this pointer itself is
a variable on your local stack which is not even
visible to any other thread; so it can't change.

I assume this was once meant to protect access
to the clntraw_private pointer, which is a global
variable and could do with some mutex protection,
and I guess at some point the code looked like this:

	mutex_lock()
	clp = clntraw_private;
	if (clp == NULL) {
		unlock and fail
	}

and some misguided soul probably moved the
pointer assignment out of the protected region
so that the code now looks the way it does.
This needs fixing.

> >  -	glibc switched to poll(), whereas tirpc still uses
> > 	select with all its limitations
> educate me... why is using poll() better than select()?

fd_set has a limit on the max file descriptor it can
accomodate (1024 I think). poll does not. So if you use
that code in apps that have files with descriptors > 1024
you will start clobbering heap or stack memory.

Under the hood, they're all the same - glibc's select
will call sys_poll.

> >  -	in tirpc, clnt_sperror uses snprintf to avoid buffer overflows,
> > 	but gets it all wrong wrt the return value of snprintf.
> hmm... how is:
>      i = snprintf(str, len, "; errno = %s", strerror(e.re_errno));
>      if (i > 0) {
>          str += i;
>          len -= i;
>      }
> wrong? looks reasonable to me... what am I missing?

snprintf returns the number of characters it *would* have
printed if the buffer size had been sufficient. It does not
return the number of characters actually printed, which is
what this code seems to assume. So if the buffer is
too small, you end up with str pointing beyond the end of
the buffer, and len a huge unsigned value. That is decidedly
not what you want :-)

> >  -	tirpc is K&R all over the place, while glibc is mostly
> > 	cleaned up (not everywhere though)
> I'm not sure why "K&R all over the place" is bad but the
> tirprc code is much better documented and much less hacker...
> Meaning, in the glibc code, fixes did not follow the original
> style... which make the fix stand out... this is not the case
> with the tirpc code...

I agree it's a matter of taste. Like  wearing bell bottom jeans
and pink shirts :-)

> >  -	tirpc bindresvport is IPv6 aware, but has a bug: if the
> > 	caller passes a sockaddr with sin_port/sin6_port set,
> > 	the routine will actually bind to htons(port).
> I must be missing something... in the AF_INET6: the port is set
> to sin6->sin6_port; which will be the first port that is tried... right?
> and that is bad?

It uses htons alright, but it forgot the ntohs

        switch (af) {
        case AF_INET:
                sin = (struct sockaddr_in *)sa;
                salen = sizeof(struct sockaddr_in);
                port = sin->sin_port; /* <--- needs ntohs */
...
		*portp = htons(port++);

> > 
> >  -	the authunix code in tirpc assumes sizeof(gid_t)
> > 	equals sizeof(int)
> this is true... are there any modern day machine architecture
> where sizeof(gid_t) == sizeof(short)?

Not as far as I know, but that's beside the point I think. This kind
of assumption is always bad.

Two more things:

 - 	tirpc does a getenv("NETNAME") which should probably be
	secure_getenv().

 -	in libc, clntudp_call uses the IP_RECVERR feature of the
	Linux kernel, so it gets notified of ICMP errors (like
	port_unreach). The TIRPC code does not, so the
	application will never see any error and has to wait
	for a timeout instead.

> Now I did not spend the time just to be argumentative with Olaf...

No offense taken. I should have probably explained my points
better than I did

> Hell... I hope he keeps poking holes... is the best thing for the
> code... but I  did spend the time because I've never been that
> impressed with the RPC in glibc in the first place... So I could
> not image any other implementation to be as bad as I perceived the
> glibc implementation is  and it turns out I was right... the tirpc
> is time tested, does support IPv6 and is well documented... among
> other thing... Plus... we have no choice... the glibc people
> will not change anything... and with Uli... nothing means nothing!
> 
> So in the end I truly do think porting rpc service (like nfs-utils,
> nis, etc) is the right thing to do...

That's where we disagree :-) I think ripping out the glibc
code and replacing it will cause a lot of maintenance for
the distros.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
