From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost servers.
Date: Tue, 23 Nov 2004 20:42:03 -0800
Message-ID: <OF90CC1740.E2696C2A-ON88256F56.00176685-88256F56.0019D29A@us.ibm.com>
References: <41A3D9CC.7040404@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net,
        Ragnar=?ISO-8859-1?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>,
        nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <41A3D9CC.7040404@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
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



nfs-admin@lists.sourceforge.net wrote on 11/23/2004 04:46:04 PM:

> Ragnar Kj=F8rstad wrote:

> >On Tue, Nov 23, 2004 at 03:28:07PM -0500, Steve Dickson wrote:
> >
> >
> >>Here is a patch that make sure the correct hostname is used
> >>in the SM_NOTIFY message what is sent from a rebooted server
> >>that has multiple network interfaces.
> >>
> >>Using the network part of the destination address, the correct netw=
ork
> >>interface is found. Then a gethostbyaddr() on that interface is don=
e,
> >>which yields the correct hostname that should be sent in the notify=

> >>message....
> >>
> >>Comments?
> >>
> >>
> >
> >It has been a while since I looked at this code, but:
> >1. What happens when you run statd with the "-n" option?
> >   Does this patch override the name the user gave?
> >
> >
> hmm.... this is a problem, since the global SM_stat_chge.mon_name
> that the -n sets is now ignored... I guess I was thinking it would be=

better
> for statd to dynamically set the name that sent the notify message.
> But it would probably be a smart to maintain the same functionality.

> Question: do people actually run multiple statds using the -n to defi=
ne
> the interface they monitor?  That's a scenario  I guess  I didn't thi=
nk
> of but
> it sound a bit awkward....

Yes, for HA NFS the server uses statd with -n and -N (notify only) for =
the
all the interfaces and aliases.
I posted a patch
http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D110064006512730&w=3D2
This fix will send the notify msg using the IP address specified with t=
he
-n option to statd. This will fix
the problem that statd in the kernel (on the client side) has of not be=
ing
able to convert mon_name to an IP address (no gethostbyname() in the
kernel) and any other clients that ignore the mon_name in the notify ms=
g
and use the source IP address from the RPC request.

> >2. Does this really find the correct hostname?
> >   If I'm not mistaken, the nfs client needs to get a SM_NOTIFY mess=
age
> >   with the hostname that it actually mounted from, right?
> >
> >
> right....

> >   This may or may not match the hostname that the server find when
> >   running gethostbyaddr on the interface's IP, so one can easily fi=
nd
> >   scenarios where this patch will cause statd to stop working.
> >
> >
> I don't think this is an issue... as long as the hostname and all of =
its
> aliases
> resolve to the same ip address, things should work since its the ip
address
> the kernel needs to find the lock that has to be reclaimed... Now the=

> problem
> arises when the hostname resolves to a different ip address....
> something this patch
> is trying to address...

> >   Now, there new behavious may actually be better, but I'm not sure=

> >   it's acceptable to change it anyway?
> >
> >
> Is this truly a big thing? to explicitly define the hostname that wil=
l
> be monitored?

> >   Could an alternative be to send out SM_NOTIFY messages for multip=
le
> >   hostnames?
> >
> I believe this is how some of the Unixs out there  do it... but that
> always seem a bit
> verbose and non-exact...

> >Both the one from gethostname() and the ones found by
> >   reverse lookup from the interfaces? Then I guess the meaning of t=
he
> >   "-n" option could be changed to _add_ a hostname to the list of
> >   names to broadcast for?
> >
> >
> Again I think this is a bit messy especially with hosts that have a t=
on
> of interfaces and
> aliases.... but anything is better than how it works today.... imho..=
.

> SteveD.

>
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real use=
rs.
> Discover which products truly live up to the hype. Start reading now.=

> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs=




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
