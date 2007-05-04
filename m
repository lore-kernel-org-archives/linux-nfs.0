From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Fri, 04 May 2007 14:52:58 -0400
Message-ID: <463B810A.7030500@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251056.03664.olaf.kirch@oracle.com>
	<46312615.2090307@RedHat.com>
	<200704270820.19718.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hk2tL-0000jY-Pd
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 11:52:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hk2tM-0005DC-3X
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 11:52:34 -0700
In-Reply-To: <200704270820.19718.olaf.kirch@oracle.com>
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

The following commits are on:
git://git.infradead.org/~steved/libtirpc.git

Olaf Kirch wrote:
>>>  -	it seems that tirpc unconditionally requires rpcbind,
>>> 	even for applications that still use pmap_set and
>>> 	friends. In the interest of a smooth transition, applications
>>> 	using the old interface should be able to expect the
>>> 	old behavior.
>> I not understanding your point... all the pmap_xxx routine are
>> supported, taking the same arguments and return same value.
>> Internally they definitely do things differently, which should
>> not be a problem...so where are you seeing the potential
>> transition problems?
> 
> It means you cannot run a binary linked against tirpc
> on a host that runs portmap but no rpcbind. E.g.
> pmap_set will simply fail if it can't connect to
> rpcbind via AF_LOCAL. I think any replacement for
> libc's sunrpc code should continue to work in a
> portmap environment.
I'm still working on this... but I am wondering why this
would be important.. why look back?

> 
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
>> Look again... clp is pointing to global data... so locks
>> are needed...
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
commit 419d35db75ab8bd8f79c424f529a6c2f7c4f5fa7
Author: Steve Dickson <steved@redhat.com>
Date:   Fri May 4 09:27:00 2007 -0400

     Fixed mutex locking problem in clnt_raw.c. One should grab the
     clntraw_lock before accessing at clntraw_private, not after.

     Signed-off-by: Steve Dickson <steved@redhat.com>


> 
>>>  -	glibc switched to poll(), whereas tirpc still uses
>>> 	select with all its limitations
>> educate me... why is using poll() better than select()?
> 
> fd_set has a limit on the max file descriptor it can
> accomodate (1024 I think). poll does not. So if you use
> that code in apps that have files with descriptors > 1024
> you will start clobbering heap or stack memory.
> 
> Under the hood, they're all the same - glibc's select
> will call sys_poll.
still looking into this... I need to port to some applications
to test this out...

> 
>>>  -	in tirpc, clnt_sperror uses snprintf to avoid buffer overflows,
>>> 	but gets it all wrong wrt the return value of snprintf.
>> hmm... how is:
>>      i = snprintf(str, len, "; errno = %s", strerror(e.re_errno));
>>      if (i > 0) {
>>          str += i;
>>          len -= i;
>>      }
>> wrong? looks reasonable to me... what am I missing?
> 
> snprintf returns the number of characters it *would* have
> printed if the buffer size had been sufficient. It does not
> return the number of characters actually printed, which is
> what this code seems to assume. So if the buffer is
> too small, you end up with str pointing beyond the end of
> the buffer, and len a huge unsigned value. That is decidedly
> not what you want :-)
commit a3a3a4e5157932c254200e3b31a78739f5878071
Author: Steve Dickson <steved@redhat.com>
Date:   Fri May 4 11:27:43 2007 -0400

     Ignore the return value of snprintf() and use strlen() instead
     to bump the pointer in clnt_sperror()

     Also removed calls to assert(), not needed.

     Signed-off-by: Steve Dickson <steved@redhat.com>

>>>  -	tirpc bindresvport is IPv6 aware, but has a bug: if the
>>> 	caller passes a sockaddr with sin_port/sin6_port set,
>>> 	the routine will actually bind to htons(port).
>> I must be missing something... in the AF_INET6: the port is set
>> to sin6->sin6_port; which will be the first port that is tried... right?
>> and that is bad?
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
commit 83cb8b02f87fe6fd7bbd903e4825f7cb38e59ec4
Author: Steve Dickson <steved@redhat.com>
Date:   Fri May 4 12:19:27 2007 -0400

     A couple ntohs() were needed in bindresvport_sa()

     Signed-off-by: Steve Dickson <steved@redhat.com>

> 
> Two more things:
> 
>  - 	tirpc does a getenv("NETNAME") which should probably be
> 	secure_getenv().
Cound not find where secure_getenv() is defined and it didn't
seem to be used in any of the glibc code, but getenv() is...

> 
>  -	in libc, clntudp_call uses the IP_RECVERR feature of the
> 	Linux kernel, so it gets notified of ICMP errors (like
> 	port_unreach). The TIRPC code does not, so the
> 	application will never see any error and has to wait
> 	for a timeout instead.
commit 40ab0c28e995786d5844bd490a31b788ecabf546
Author: Steve Dickson <steved@redhat.com>
Date:   Fri May 4 14:26:56 2007 -0400

     Added IP_RECVERR processing with to clnt_dg_call() so
     application will see errors instead of timing out

     Signed-off-by: Steve Dickson <steved@redhat.com>


> 
> That's where we disagree :-) I think ripping out the glibc
> code and replacing it will cause a lot of maintenance for
> the distros.
Don't worry... that glibc code is going anywhere... but
when IPv6 supported is need, I'm hopeful the Linux version
of libtirpc will be an option...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
