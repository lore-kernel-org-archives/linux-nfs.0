From: mike@waychison.com
Subject: RE: [autofs] [PATCH/RFC 0/2] Userspace RPC proxying
Date: Tue, 8 Mar 2005 16:06:11 -0500 (EST)
Message-ID: <38122.66.11.176.22.1110315971.squirrel@webmail1.hrnoc.net>
References: <482A3FA0050D21419C269D13989C611307CF4C14@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: mike@waychison.com, "linux-nfs" <nfs@lists.sourceforge.net>,
	"autofs mailing list" <autofs@linux.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8luJ-0004Qp-1P
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 13:06:23 -0800
Received: from relay1.hrnoc.net ([216.120.226.254])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D8luI-0000zi-6d
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 13:06:22 -0800
Received: from smtp-1.hrnoc.net ([216.120.225.37])
	by relay1.hrnoc.net with esmtp (Exim 4.41 (FreeBSD))
	id 1D8luE-00009m-Gt
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 16:06:18 -0500
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4C14@lavender-fe.eng.netapp.com>
To: "Lever, Charles" <Charles.Lever@netapp.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>> It's less unsafe than SO_REUSEADDR, however it completely ignores
>> TIME_WAIT,  which has two purposes (according to W.R. Stevens):
>>
>> - If the client performs the active close, it allows the socket to
>> remember to resend the final ACK in response to the server's FIN.
>> Otherwise the client would respond with a RST.
>>
>> - It ensures that no re-incarnations of the same four-tuple
>> occur within 2
>> * MSL, ensuring that no packets that were lost on the network from the
>> first incarnation get used as part of the new incarnation.
>>
>> Avoiding TIME_WAIT altogether keeps TCP from doing a proper
>> full-duplex
>> close and also allows old packets to screw up TCP state.
>
> right, there are cases where proper connection close processing is
> required.  and you don't need to worry much about duplicate request
> caching for the services we're talking about here, so it's probably not
> as critical for rpcproxyd.
>
>> Which timeout is 5 minutes? (sparing me the trouble of finding it
> myself).
>
> the RPC client side idle timeout is 5 minutes in the reference
> implementation (Solaris).

Hmm. Okay. Without looking at the code, I'm going to assume that this is
handled in the core rpc code, and not in the per-transport bits.

If this is indeed the case, then the client will close the connection to
the proxy after five minutes, which in turns kicks off a timer in the
proxy to close the unused transport after 30 seconds.

Though I better dig deeper before I claim this is the case ;)

>> I figured 30 for caching un-used tcp connections sounded like a good
>> number as it means that if TIME_WAIT period is 2 minutes,
>> that the most
>> TIME_WAIT connections that you can have to a given remote
>> service at any time is 4.
>>
>> A bit more thought could be had for timeouts (wishlist):
>> - TCP connect()s aren't timedout. (uses EINPROGRESS, but will wait
>> indefinitely, which I think is bounded by the kernel anyway).
>
> there is a SYN retry limit controllable via sysctl for all sockets on
> the system.  by default the active end tries sending SYN 6 times with
> exponential backoff.  eventually the connection attempt will time out i=
f
> the remote peer doesn't respond with SYN,ACK after the last SYN is sent=
.
> i think it's on the order of a couple of minutes.

Great. This is probably a ENETUNREACH error.

>
>> - UDP retransmission occurs in the proxy itself, which is currently
>> hardcoded to retry 5 times, once every two seconds.  I can
>> trivially set it up so that it gets the actual timeout values from the
>
>> client though and use those parameters.
>
> that should probably have exponential backoff, but it probably isn't
> critical.
>

Yup.  10 seconds of retries probably isn't big enough.  Will add the
needed logic when I get the chance.

>> > you will also need a unique connection for each
>> program/version number
>> > combination to a given server; ie you can't share a single
>> socket among
>> > different program/version numbers (even though some
>> implementations try
>> > to do this, it is a bad practice, in my opinion).
>> >
>>
>> So, I know I discussed this with you last week, however I was
>> under the
>> impression that that was needed for the case where you
>> support re-binding
>> of the transport.  I'm not up to speed of who are the users of such a
>> thing (I'm assuming NFSv4).
>
> if you expect to cache these associations for a long time, you will nee=
d
> to rebind every so often in case the server decides to move the service
> to another port.  with UDP, anyway.
>
> you also can't assume that all the services you need to talk to
> (PORTMAP, NFS, MOUNTD, etc) will live on the same port.  for a truly
> general implementation you will need to use a separate connection for
> each service.

rpcproxyd will make as many outbound connections as needed.  They are
indexed by:

(
  addrlen =3D=3D conn->addrlen
  && !memcmp(addr, conn->addr, addrlen)
  && domain =3D=3D conn->domain  /* eg: AF_INET */
  && type   =3D=3D conn->type    /* eg: SOCK_STREAM */
)

There is no re-using a connection based on prog && vers.

As such, if the service moves a port, it will be the client's
responsibility to either a) pass in the updated addr in a call the
clntproxy_create or b) pass in addr with addr->sin_port =3D=3D 0 so the
portmapper is consulted again.

I don't think any of the existing rpc classes support transparent
rebinding of service address.

>
> but you said "assuming NFSv4," so maybe none of this matters.  i would
> hope that a connection cache would be good for any application using
> RPC.

Well, I'm thinking that with NFSv4 you may want to rebind the underlying
socket instead of creating a new socket with it comes time to migrate.

>
>> > to support IPv6 you will need support for rpcbind versions
>> 3 and 4; but
>> > that may be an issue outside of rpcproxyd.
>> >
>>
>> Okay.  I'm not so familiar with RPCB, but it is just a PMAP
>> on steroids, right?
>
> the later versions of the rpcbind protocol support additional operation=
s
> that allow IPv6-style information to be returned.  version 2 does not
> support IPv6, as far as i know, but i'm no expert.
>

Great.

This brings up the question though: does current util-linux even support
IPv6?  It (the one on my debian box) has explicit calls to pmap_getport,
which appears to be IPv4 only.

Thanks,

Mike Waychison



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
