From: mike@waychison.com
Subject: RE: [PATCH/RFC 0/2] Userspace RPC proxying
Date: Tue, 8 Mar 2005 13:22:59 -0500 (EST)
Message-ID: <37835.66.11.176.22.1110306179.squirrel@webmail1.hrnoc.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: autofs mailing list <autofs@linux.kernel.org>,
        linux-nfs <nfs@lists.sourceforge.net>, mike@waychison.com
To: "Lever, Charles" <Charles.Lever@netapp.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> hi mike-
>
>> Every once in a while, we see complaints that nfs mounts are
>> failing due
>> to there being no more reserved ports available for outbound rpc
>> communication.  This often happens when using TCP transports,
>> because all
>> outbound connections that are closed go into a TIME_WAIT state.
>
> i know that steved has also been looking at this problem.  he found that
> user-land uses TCP connections with abandon and has put it on a diet.
> and, the client side should take care to avoid using reserved ports
> unless it is absolutely necessary.

Yup. I tested out SteveD's stuff and it certainly cut down on reserved
port usage.  However, I was still able locally DOS my test client by
mounting several thousand mounts within a minute or so.  The problem is
that talking to mountd still requires the reserved port :\

>
>> For various reasons, avoiding the TIME_WAIT state using connect(fd,
>> {AF_UNSPEC}, ...) or doing SO_REUSEADDR may not be the safest way to
>> handle things.
>
> i have a patch for the kernel RPC client to use AF_UNSPEC to reuse the
> port number on connections.  before i head into the wilderness, what's
> unsafe about that?

It's less unsafe than SO_REUSEADDR, however it completely ignores
TIME_WAIT,  which has two purposes (according to W.R. Stevens):

- If the client performs the active close, it allows the socket to
remember to resend the final ACK in response to the server's FIN. 
Otherwise the client would respond with a RST.

- It ensures that no re-incarnations of the same four-tuple occur within 2
* MSL, ensuring that no packets that were lost on the network from the
first incarnation get used as part of the new incarnation.

Avoiding TIME_WAIT altogether keeps TCP from doing a proper full-duplex
close and also allows old packets to screw up TCP state.

>
>> rpcproxyd will create outbound connections and multiplex the
>> transports
>> with any number of simultaneous clients.  There is no support for
>> re-binding your transport once created.  It will also cache outbound
>> server connections for 30 seconds after last use, which
>> greatly helps keep the number of ports used down in a mount-storm
> situation.
>
> the typical RPC client-side connection timeout is 5 minutes.  any reason
> not to use that value instead of 30 seconds?

The timeouts used currently in rpcproxyd were chosen arbitrarily.

Which timeout is 5 minutes? (sparing me the trouble of finding it myself).

I figured 30 for caching un-used tcp connections sounded like a good
number as it means that if TIME_WAIT period is 2 minutes, that the most
TIME_WAIT connections that you can have to a given remote service at any
time is 4.

A bit more thought could be had for timeouts (wishlist):
- TCP connect()s aren't timedout. (uses EINPROGRESS, but will wait
indefinitely, which I think is bounded by the kernel anyway).
- UDP retransmission occurs in the proxy itself, which is currently
hardcoded to retry 5 times, once every two seconds.  I can trivially set
it up so that it gets the actual timeout values from the client though and
use those parameters.

>
> you will also need a unique connection for each program/version number
> combination to a given server; ie you can't share a single socket among
> different program/version numbers (even though some implementations try
> to do this, it is a bad practice, in my opinion).
>

So, I know I discussed this with you last week, however I was under the
impression that that was needed for the case where you support re-binding
of the transport.  I'm not up to speed of who are the users of such a
thing (I'm assuming NFSv4).

Also, AFAICT, the glibc sunrpc stuff will actually bind you to a program
even if the version doesn't exist.  This is used by rpcinfo [-u | -t] for
udpping / tcpping.

> to support IPv6 you will need support for rpcbind versions 3 and 4; but
> that may be an issue outside of rpcproxyd.
>

Okay.  I'm not so familiar with RPCB, but it is just a PMAP on steroids,
right?

It wouldn't be needed for the basic common use of rpcproxyd, however it
would likely be required for cases where clntproxy_create has to do some
lookups (eg: port == 0, maybe even addr == NULL).

>> rpcproxyd is written as a single-threaded/no-signals/select-based
> daemon.
>
> will using select be a scalability issue?  you might be better off with
> something like libevent or using epoll.
>

It may become a scalability issue, although I don't know what the typical
numbers are for live descriptors.  It was written with select cause that's
what I know ;)

In any event, using epoll would likely be a good thing to do.

Mike Waychison
