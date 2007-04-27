From: Peter Staubach <staubach@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Fri, 27 Apr 2007 10:01:53 -0400
Message-ID: <46320251.8050900@redhat.com>
References: <17958.48121.280256.493824@notabene.brown>	<200704251056.03664.olaf.kirch@oracle.com>	<46312615.2090307@RedHat.com>
	<200704270820.19718.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhR1T-0007HT-A0
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:02:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhR1V-00019l-Bo
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:02:09 -0700
In-Reply-To: <200704270820.19718.olaf.kirch@oracle.com>
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
> On Friday 27 April 2007 00:22, Steve Dickson wrote:
>   
>> So the glibc can indeed allocate memory a ton of gids
>> but then only sends NGRPS of them... which is a complete
>> waste of memory and time...  imho..
>>     
>
> No. If you don't do this, you will not get *any* gids.
> getgroups simply fails if the array you give it is too short.
> And tirpc deals with that rather ungracefully by calling
> abort(), of all things.
>
>   

It is a distinct possibility that calling abort() is the wrong thing,
but so is sending out a message with only part of the gid list.  The
request can fail due to authentication problems, the user looks and
see that he is indeed in the right group(s), and then can't figure
out why things didn't work right.

There isn't a clear cut right answer, but the described behavior is
at least definitive.  There were a _lot_ of discussions inside of
Sun, comp.protocols.nfs, and at Connectathons regarding this issue,
without clear resolutions that were better than the current behavior.

>> Also the only two place gethostbyname() is used in tirpc is in
>> getrpcport() and in the a few calls down from authdes_refresh().
>>
>> Now there are calls to mutex_lock/unlock so in the end there
>> multithread support... at least in that part of the code...
>>     
>
> Ah, okay.
>
>   

The TI-RPC code is definitely thread-safe and many portions are also
MT-hot.  Many of the Solaris RPC based daemons are multi-threaded,
like mountd, for example.

This version of the library may or may not be MT-safe, but newer
versions are definitely safe.  Perhaps the Bull people could tell
us how old the library is?


>>>  -	it seems that tirpc unconditionally requires rpcbind,
>>> 	even for applications that still use pmap_set and
>>> 	friends. In the interest of a smooth transition, applications
>>> 	using the old interface should be able to expect the
>>> 	old behavior.
>>>       
>> I not understanding your point... all the pmap_xxx routine are
>> supported, taking the same arguments and return same value.
>> Internally they definitely do things differently, which should
>> not be a problem...so where are you seeing the potential
>> transition problems?
>>     
>
> It means you cannot run a binary linked against tirpc
> on a host that runs portmap but no rpcbind. E.g.
> pmap_set will simply fail if it can't connect to
> rpcbind via AF_LOCAL. I think any replacement for
> libc's sunrpc code should continue to work in a
> portmap environment.
>
>   

This sounds like a good goal to add to the list of work to do.

>>>  -	tirpc does truly bizarre things, eg in clnt_raw.c
>>> 	it declares a local variable, and then acquires
>>> 	a mutex to check this local variable for NULL:
>>>
>>> 	       mutex_lock(&clntraw_lock);
>>> 	       if (clp == NULL) {
>>> 	               mutex_unlock(&clntraw_lock);
>>> 	               return (RPC_FAILED);
>>> 	       }
>>> 	       mutex_unlock(&clntraw_lock);
>>>       
>> Look again... clp is pointing to global data... so locks
>> are needed...
>>     
>
> Yes, clp is *pointing* at global data, so the data it
> points at may change. But this pointer itself is
> a variable on your local stack which is not even
> visible to any other thread; so it can't change.
>
> I assume this was once meant to protect access
> to the clntraw_private pointer, which is a global
> variable and could do with some mutex protection,
> and I guess at some point the code looked like this:
>
> 	mutex_lock()
> 	clp = clntraw_private;
> 	if (clp == NULL) {
> 		unlock and fail
> 	}
>
> and some misguided soul probably moved the
> pointer assignment out of the protected region
> so that the code now looks the way it does.
> This needs fixing.
>
>   

It seems to me that you are still missing the point of the lock.

The lock is not being used to protect the assignment of the address
of clnt_raw_private to clp, it is being used to ensure that clp is not
being used before clnt_raw_private is completely initialized.

The lock is also used to ensure that multiple copies of clnt_raw_private
are not allocated.

Arguably, this could have been implemented using a different locking
strategy, one which recovered from discovered races, instead of
preventing them upfront, but it works and is correct.

>>>  -	glibc switched to poll(), whereas tirpc still uses
>>> 	select with all its limitations
>>>       
>> educate me... why is using poll() better than select()?
>>     
>
> fd_set has a limit on the max file descriptor it can
> accomodate (1024 I think). poll does not. So if you use
> that code in apps that have files with descriptors > 1024
> you will start clobbering heap or stack memory.
>
> Under the hood, they're all the same - glibc's select
> will call sys_poll.
>
>   

Here is a place where a newer version of the TI-RPC library would help.

>>>  -	in tirpc, clnt_sperror uses snprintf to avoid buffer overflows,
>>> 	but gets it all wrong wrt the return value of snprintf.
>>>       
>> hmm... how is:
>>      i = snprintf(str, len, "; errno = %s", strerror(e.re_errno));
>>      if (i > 0) {
>>          str += i;
>>          len -= i;
>>      }
>> wrong? looks reasonable to me... what am I missing?
>>     
>
> snprintf returns the number of characters it *would* have
> printed if the buffer size had been sufficient. It does not
> return the number of characters actually printed, which is
> what this code seems to assume. So if the buffer is
> too small, you end up with str pointing beyond the end of
> the buffer, and len a huge unsigned value. That is decidedly
> not what you want :-)
>
>   

Yup, that was a bug, and has already been fixed in a newer version of the
library.

>>>  -	tirpc is K&R all over the place, while glibc is mostly
>>> 	cleaned up (not everywhere though)
>>>       
>> I'm not sure why "K&R all over the place" is bad but the
>> tirprc code is much better documented and much less hacker...
>> Meaning, in the glibc code, fixes did not follow the original
>> style... which make the fix stand out... this is not the case
>> with the tirpc code...
>>     
>
> I agree it's a matter of taste. Like  wearing bell bottom jeans
> and pink shirts :-)
>
>   

I think that a short bit of work would convert the argument lists from
K&R style to ANSI, so that shouldn't be a factor.

We could also take a shot at addressing the multitude of types which
are used and update them to the current thinking.

>>>  -	tirpc bindresvport is IPv6 aware, but has a bug: if the
>>> 	caller passes a sockaddr with sin_port/sin6_port set,
>>> 	the routine will actually bind to htons(port).
>>>       
>> I must be missing something... in the AF_INET6: the port is set
>> to sin6->sin6_port; which will be the first port that is tried... right?
>> and that is bad?
>>     
>
> It uses htons alright, but it forgot the ntohs
>
>         switch (af) {
>         case AF_INET:
>                 sin = (struct sockaddr_in *)sa;
>                 salen = sizeof(struct sockaddr_in);
>                 port = sin->sin_port; /* <--- needs ntohs */
> ...
> 		*portp = htons(port++);
>
>   

This seems like another bug that is already fixed in newer versions of
TI-RPC.

>>>  -	the authunix code in tirpc assumes sizeof(gid_t)
>>> 	equals sizeof(int)
>>>       
>> this is true... are there any modern day machine architecture
>> where sizeof(gid_t) == sizeof(short)?
>>     
>
> Not as far as I know, but that's beside the point I think. This kind
> of assumption is always bad.
>
> Two more things:
>
>  - 	tirpc does a getenv("NETNAME") which should probably be
> 	secure_getenv().
>
>  -	in libc, clntudp_call uses the IP_RECVERR feature of the
> 	Linux kernel, so it gets notified of ICMP errors (like
> 	port_unreach). The TIRPC code does not, so the
> 	application will never see any error and has to wait
> 	for a timeout instead.
>   

This seems like a porting issue to me.  Thank you for pointing it
out so that it can get addressed.

>   
>> Now I did not spend the time just to be argumentative with Olaf...
>>     
>
> No offense taken. I should have probably explained my points
> better than I did
>
>   
>> Hell... I hope he keeps poking holes... is the best thing for the
>> code... but I  did spend the time because I've never been that
>> impressed with the RPC in glibc in the first place... So I could
>> not image any other implementation to be as bad as I perceived the
>> glibc implementation is  and it turns out I was right... the tirpc
>> is time tested, does support IPv6 and is well documented... among
>> other thing... Plus... we have no choice... the glibc people
>> will not change anything... and with Uli... nothing means nothing!
>>
>> So in the end I truly do think porting rpc service (like nfs-utils,
>> nis, etc) is the right thing to do...
>>     
>
> That's where we disagree :-) I think ripping out the glibc
> code and replacing it will cause a lot of maintenance for
> the distros.
>   

I am curious what basis that you are using for this?  Why will this
cause either more or less maintenance for distros?

It seems to me that this would give us some RPC code, which we could
support, which was newer than the current glibc code, and would have
more people working on and supporting it.  That all seems like goodness
to me.  The current situation is that we can't maintain the RPC code
at all, which is not goodness at all.

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
