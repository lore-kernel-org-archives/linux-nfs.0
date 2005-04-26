From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Client sees delay  in io when nfs server starts after failover
Date: Tue, 26 Apr 2005 07:30:27 -0700
Message-ID: <482A3FA0050D21419C269D13989C611307CF4C85@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQR5B-000242-9v
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:30:37 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DQR59-0006Jm-AX
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:30:37 -0700
To: "mehta kiran" <kiranmehta1981@yahoo.com>
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

> Hi ,=20
>       But client displays message "nfs server not=20
>       responding" even if following messages are=20
>       given by rpcinfo.
>    =20
>       #rpcinfo -u <server> 100003
>        program 100003 version 2 ready and waiting
>        program 100003 version 3 ready and waiting
>        program 100003 version 4 ready and waiting=20
>=20
>       #rpcinfo -t <server> 100003
>        program 100003 version 2 ready and waiting
>        program 100003 version 3 ready and waiting
>        program 100003 version 4 ready and waiting=20
>=20
>       Should rpc calls over tcp respond  if server
>       is not available

on TCP connections, the client will report "server not responding" when
it hasn't received a reply from the server after a major timeout.
you'll get one of these messages for every RPC request that has timed
out.

if the client hasn't managed to establish a new connection yet, then,
yes you can expect to see the rpcinfo results like the above and still
have a delay in response.  the RPC client can't send RPC requests or
receive replies until a TCP connection has been established with the
server.  that can take a while; SYN retries have an exponential backoff.

i've also seen the case where the connection state remains on both sides
after a network partition, but the client's network layer is just
hanging onto the byte stream.  the RPC client retransmits, but the
client's network layer buffers the requests.  i imagine that the network
layer is also retransmitting the bytes, but because of exponential
backoff, it is waiting a long time before retrying.

some experts say the best thing to do in this case is for the client to
tear down it's connection and simply retry to connect.  that may result
in faster recovery from server reboot/failover or network partition, but
it also has some disadvantages.

> --- "Lever, Charles" <Charles.Lever@netapp.com> wrote:
> > >     I am using sles9 sp1 rc5 (2.6.5-7.139 kernel)
> > >     NFS server is running on a machines.
> > >     Client access server and does moderate amount=20
> > >     of io on mounted filesystem.
> > >     When nfs server switches to other machine ,=20
> > >     nfs client has to wait for 2-3 minutes so as
> > >     to continue io on new nfs server.
> > >     Sometimes client sees delay of  20-30
> > >     seconds only.Why is this difference seen in
> > >     different runs/executions.
> > >   =20
> > >     Is this the expected behaviour ?
> >=20
> > i'm speculating, but i expect the delay is due to
> > the time it takes the
> > client TCP layer to reconnect to the new server
> > host.  i notice when a
> > client loses a TCP connection to a server (even
> > without a failover) it
> > takes as long as 2-3 minutes to reconnect.  it's on
> > my list of things to
> > look at improving.
> >=20
>=20
> __________________________________________________
> Do You Yahoo!?
> Tired of spam?  Yahoo! Mail has the best spam protection around=20
> http://mail.yahoo.com=20
>=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
