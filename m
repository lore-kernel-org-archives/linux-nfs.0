From: "Bruce Allan" <bruce.allan@us.ibm.com>
Subject: Re: nfs-utils patch to statd for multi-homed hosts
Date: Thu, 6 Jun 2002 15:13:55 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF2D065FD8.917E89A0-ON88256BCE.0064AF54@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17G5X0-0002nx-00
	for <nfs@lists.sourceforge.net>; Thu, 06 Jun 2002 15:14:59 -0700
To: Ragnar =?iso-8859-1?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


See my responses below...

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187


                                                                       =
                                                                       =
     =20
                      Ragnar Kj=F8rstad                                =
                                                                       =
       =20
                      <nfs@ragnark.vestdat        To:       Bruce Allan=
/Beaverton/IBM@IBMUS                                                   =
     =20
                      a.no>                       cc:       nfs@lists.s=
ourceforge.net                                                         =
     =20
                      Sent by:                    Subject:  Re: [NFS] n=
fs-utils patch to statd for multi-homed hosts                          =
     =20
                      nfs-admin@lists.sour                             =
                                                                       =
     =20
                      ceforge.net                                      =
                                                                       =
     =20
                                                                       =
                                                                       =
     =20
                                                                       =
                                                                       =
     =20
                      06/01/2002 03:27 AM                              =
                                                                       =
     =20
                                                                       =
                                                                       =
     =20
                                                                       =
                                                                       =
     =20



> On Fri, May 31, 2002 at 01:18:27PM -0700, Bruce Allan wrote:
> > The attached patch provides the capability for statd to work with
> > multi-homed hosts (i.e. NFS servers and clients with more than one =
IP
> > interface each) as until now listed as a "FIXME" comment in
> > utils/statd/rmtcall.c
> Great! :-)

> > The theory is when a server or client crashes, reboots, and attempt=
s to
> > notify the other of it's status change, if either host's interface =
on
which
> > the connection was originally made is no longer functional, statd w=
ill
> > attempt to use alternate interfaces if they exist.  This is made
possible
> > by changing the addr member of the notify_list structure to a list =
of
> > addresses equivalent to that returned by a gethostbyname() call.
Failed
> > attempts at notifying an address removes that address from the list=
.

> Are you saying notifications used to be sent out on the interface whe=
re
> the connection happened? I thought it only happened on the primary
> interface....

That's not what I was trying to say, and you are correct - notification=
s
were/are sent out on the primary interface.  But, if the primary interf=
ace
for some reason stops working on either the client or server during the=

change in state there is a problem.  The most likely case of this would=
 be
when the server crashes and it's primary interface is hosed upon reboot=
.

> Does the new code work with aliases as well as physical interfaces?

Not really; it starts with the IP address as provided on stable storage=

(i.e. /var/lib/nfs/sm/*) and does a reverse lookup followed by a forwar=
d
lookup and tries to notify each of the addresses in the h_addr_list in
succession until one is valid.  The new code doesn't check for aliases.=


> How does this interact with the "--name" switch?

It should work fine with the use of the "--name" switch.  When a host g=
ets
an SM_MON request which is specified with the "--name" switch, a forwar=
d
lookup is done on that name and the IP address is saved to stable stora=
ge.
When a change of state occurs and the host needs to send an SM_NOTIFY, =
it
does the reverse and forward lookups to get the list of addresses to tr=
y.
By doing the reverse lookup, we should get the same hostname as provide=
d
with the "--name" switch.

> I believe --name originally replaced the gethostbyname() name with th=
e
> user-supplied one. Now that there are multiple interfaces to worry ab=
out
> the old approach no longer works well.
> I see a few different alternatives of fixing that:
> 1. Remove "--name". It was mostly written to fix the exact same probl=
em
>    that your patch fixes in a bettery way. Unfortenately this will no=
t
>    solve the problem with multiple names mapping to the same ip.
> 2. Change "--name" so that it _adds_ the hostname to the list of
>    names to use in the notification-message, rather than replacing
>    the existing one(s). I suppose it should also be changed to accept=

>    mulitple hostnames.
> 3. Could we possible send the IP to the clients rather than the
>    hostnames? That would eliminate the problem of mulitple names
>    matching the same hostname.
>
> I suppose I should go read the spec and find out how this really work=

> before making comments, but I don't have the time just now, so take t=
he
> comments with a grain of salt..

For option 1, I can't think of a reason off-hand, but I suspect there m=
ay
still be cases for keeping the "--name" switch around, even if just for=

historical reasons.

For options 2 and 3, the Open Group Technical Standard - Protocols for
Internetworking: XNFS, Version 3W, page 173 states that an SM_NOTIFY se=
nds
'"mon_name" [which] is the name of the host that had the state change';=
 so
I don't think these suggestions are possible.

Thanks for the feedback!
Bruce.

=



_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
