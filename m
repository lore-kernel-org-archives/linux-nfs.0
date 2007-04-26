From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Thu, 26 Apr 2007 18:22:13 -0400
Message-ID: <46312615.2090307@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<20070424171708.GA7936@infradead.org> <462E43CC.6040806@RedHat.com>
	<200704251056.03664.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhCMc-0006Bv-56
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 15:22:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhCMe-0001Wr-3C
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 15:23:00 -0700
In-Reply-To: <200704251056.03664.olaf.kirch@oracle.com>
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

Olaf Kirch wrote:
> On Tuesday 24 April 2007 19:52, Steve Dickson wrote:
>> In theory yes...  but unfortunately Transport Independent
>> RPC code is much different than the RPC we have in glibc.
> 
> Still, there's a whole load of shared code, and this is where
> I agree with Christoph that it would be foolish to throw away
> the work that went into the glibc code. 

> The buffer overflow fix I mentioned is just one such thing - 
Fixed in git://git.infradead.org/~steved/libtirpc.git
(commit 30431c6d846eab1bc6b7a3a91a7894f3acf2680f)

But there was code that check for nodesize being zero
so it not completely clear that this buffer overflow
was a real threat...

> I did a diff of the files common in glibc and tirpc, and here are some 
> of the things I found.
> 
>  -	glibc authunix_create_default works if the process has
> 	more than NGRPS gids. tirpc wil fail
Note the following comment in the glibc code:
   /* This braindamaged Sun code forces us here to truncate the
      list of groups to NGRPS members since the code in
      authuxprot.c transforms a fixed array.  Grrr.  */
So the glibc can indeed allocate memory a ton of gids
but then only sends NGRPS of them... which is a complete
waste of memory and time...  imho..

> 
>  -	glibc tries to be more multithread friendly, by using
> 	things like gethostbyname_r instead of gethostbyname.
> 	tirpc doesn't.
Well since gethostbyname_r() is a GNU extension it understandable
why its not in the BSD based code... Also in tirpc, gethostbyname()
routine is *not* used in the highly used  clnt_create() call as
its is in glibc . In tirpc the routine getaddrinfo() is used to
resolve host names in clnt_create() and I don't think there is a
thread safe version of that...

Also the only two place gethostbyname() is used in tirpc is in
getrpcport() and in the a few calls down from authdes_refresh().

Now there are calls to mutex_lock/unlock so in the end there
multithread support... at least in that part of the code...


>  -	it seems that tirpc unconditionally requires rpcbind,
> 	even for applications that still use pmap_set and
> 	friends. In the interest of a smooth transition, applications
> 	using the old interface should be able to expect the
> 	old behavior.
I not understanding your point... all the pmap_xxx routine are
supported, taking the same arguments and return same value.
Internally they definitely do things differently, which should
not be a problem...so where are you seeing the potential
transition problems?

> 
>  -	tirpc does truly bizarre things, eg in clnt_raw.c
> 	it declares a local variable, and then acquires
> 	a mutex to check this local variable for NULL:
> 
> 	       mutex_lock(&clntraw_lock);
> 	       if (clp == NULL) {
> 	               mutex_unlock(&clntraw_lock);
> 	               return (RPC_FAILED);
> 	       }
> 	       mutex_unlock(&clntraw_lock);
Look again... clp is pointing to global data... so locks
are needed...

> 
>  -	tirpc has a mechanism that lets you register
> 	server side auth flavors dynamically; libc
> 	doesn't.
> 
>  -	glibc switched to poll(), whereas tirpc still uses
> 	select with all its limitations
educate me... why is using poll() better than select()?

> 
>  -	in tirpc, svc.c seems to be thread safe, whereas
> 	glibc isn't.
> 
>  -	tirpc lets the application control the maximum record
> 	size, making DoS attacks just a little harder.
> 
>  -	in tirpc, xdr_mem.c has different ops for aligned vs
> 	unaligned buffers, for what it's worth.
> 
>  -	in tirpc, clnt_sperror uses snprintf to avoid buffer overflows,
> 	but gets it all wrong wrt the return value of snprintf.
hmm... how is:
     i = snprintf(str, len, "; errno = %s", strerror(e.re_errno));
     if (i > 0) {
         str += i;
         len -= i;
     }
wrong? looks reasonable to me... what am I missing?

> 
>  -	tirpc is K&R all over the place, while glibc is mostly
> 	cleaned up (not everywhere though)
I'm not sure why "K&R all over the place" is bad but the
tirprc code is much better documented and much less hacker...
Meaning, in the glibc code, fixes did not follow the original
style... which make the fix stand out... this is not the case
with the tirpc code...

> 
>  -	tirpc bindresvport is IPv6 aware, but has a bug: if the
> 	caller passes a sockaddr with sin_port/sin6_port set,
> 	the routine will actually bind to htons(port).
I must be missing something... in the AF_INET6: the port is set
to sin6->sin6_port; which will be the first port that is tried... right?
and that is bad?

> 	the libc bindresvport implementation also has a small
> 	optimization in that it will continue searching where the
> 	previous call to bindresvport left off, rather than starting
> 	all over from 600.
I ironic you bring this up.. this is the result of a bug I found
and with this experience I learned how difficult it truly is
to get things fixed in glibc.. anyways this is fixed with
in my git tree with:
commit c254b435007ebd4ed471737198975d5ccf4e7949

> 
>  -	the authunix code in tirpc assumes sizeof(gid_t)
> 	equals sizeof(int)
this is true... are there any modern day machine architecture
where sizeof(gid_t) == sizeof(short)?

> 
>  -	the glibc RPC client side seems to be thread safe, whereas
> 	tirpc seems to be lacking in some areas (see rpc_thread.c)
I think *seems* is the key word here... since I can not find any
functions that make use of these routines but there is a lot
of glibc black magic in that file so maybe indirectly they are...

> 
> I stopped reading the code after an hour, but I think this list could
> be extended quite a bit.
Please catch your breath... and continue on! :-)

Again I want to thank Olaf for taking the time which caused me
to take the time to take close look.... and I'm glad I did...
I actually feel tirpc (least the library code) is much better
shape that that I thought it was...

Now I did not spend the time just to be argumentative with Olaf...
Hell... I hope he keeps poking holes... is the best thing for the
code... but I  did spend the time because I've never been that
impressed with the RPC in glibc in the first place... So I could
not image any other implementation to be as bad as I perceived the
glibc implementation is  and it turns out I was right... the tirpc
is time tested, does support IPv6 and is well documented... among
other thing... Plus... we have no choice... the glibc people
will not change anything... and with Uli... nothing means nothing!

So in the end I truly do think porting rpc service (like nfs-utils,
nis, etc) is the right thing to do...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
