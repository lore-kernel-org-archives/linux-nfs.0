From: Ragnar =?iso-8859-15?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost servers.
Date: Wed, 24 Nov 2004 21:35:24 +0100
Message-ID: <20041124203524.GJ19342@vestdata.no>
References: <20041124173525.GI19342@vestdata.no> <OFB654AEC9.6741BC01-ON88256F56.006576D7-88256F56.0066D21B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net,
        Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFB654AEC9.6741BC01-ON88256F56.006576D7-88256F56.0066D21B@us.ibm.com>
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

On Wed, Nov 24, 2004 at 10:43:04AM -0800, Marc Eshel wrote:
> > "10.0.0.1" is a character string as much as any - unless the
> > specification says something more about this?
>=20
> That would help statd that is running in the kernel and can not do
> gethostbyname(). The problem right now is that the kernel statd ignores=
 the
> mon_name in the notify msg altogether and uses the uses the source IP
> address from the RPC request. It would be nice if we send the notify ms=
g
> from the same source as is specified in the -n option. This way what ev=
er
> the client uses will result in the same the IP.
> see:
>       http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D110064006512730&w=
=3D2

Yes, let me adjust my proposal:

And I think that could be something along the lines:

* loop over all available interfaces
* for each interface, send a message to all clients that belong on
  this subnet
* the message could be based on the IP or gethostbyaddr(IP).
+ make sure the outgoing message is sent from the interface it
  applies to, so that it works with clients that look at the
  source address instead of the name. (or look at both, but only
  accept the message if they match).


I think this would cover absolutely all cases (with the exception of
source NAT, and that's pretty obscure!?), so I think it's fair to remove
"-n". (rather, it should give the user a message the option is obsolete
and is beeing ignored)


OK, so I didn't actually look closely at the code to if this could be
easily coded, but how hard can it be? :-)


--=20
Ragnar Kj=F8rstad
Software Engineer
Scali - http://www.scali.com
High Performance Clustering


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
