From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost servers.
Date: Wed, 24 Nov 2004 10:43:04 -0800
Message-ID: <OFB654AEC9.6741BC01-ON88256F56.006576D7-88256F56.0066D21B@us.ibm.com>
References: <20041124173525.GI19342@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net,
        Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <20041124173525.GI19342@vestdata.no>
To: Ragnar=?ISO-8859-1?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
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



nfs-admin@lists.sourceforge.net wrote on 11/24/2004 09:35:25 AM:

> On Wed, Nov 24, 2004 at 07:00:08AM -0500, Steve Dickson wrote:
> > >If that's the case, are we allowed to just send the IP instead of =
the
> > >name?
> > >
> > >
> > No, since the spec says a the id_mon needs to be character string..=
..

> "10.0.0.1" is a character string as much as any - unless the
> specification says something more about this?

That would help statd that is running in the kernel and can not do
gethostbyname(). The problem right now is that the kernel statd ignores=
 the
mon_name in the notify msg altogether and uses the uses the source IP
address from the RPC request. It would be nice if we send the notify ms=
g
from the same source as is specified in the -n option. This way what ev=
er
the client uses will result in the same the IP.
see:
      http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D110064006512730&w=
=3D2

>
>
> > >- If you have aliases (eth0, eth0:0) with different IPs but on the=

> > > same network. The current patch (if I read it correctly) will the=
n
> > > use the name from the last alias, which is kind of random.
> >
> > Well it would not be random, it would be the first interface....
> >
> > >The second case may be very relevant to the HA-problem which "-n" =
was
> > >originally added for.
> > >
> > >
> > Yes... the -n flag wold be the answer here...

> Unless, of course, a more general fix would handle this automatically=
.

> And I think that could be something along the lines:

> - loop over all available interfaces
> - for each interface, send a message to all clients that belong on
> this subnet
> - the message could be based on the IP or gethostbyaddr(IP).
>
> In short, this is exactly like what your patch does except that:
> - if there are multiple matching interfaces (e.g. aliases) we
> send messages for all
> - I still don't understand why we don't send the IP instead of
> the name.

>
> Unlike sending messages for all names to all clients it's not too
> verbose.

> --
> Ragnar Kj=F8rstad
> Software Engineer
> Scali - http://www.scali.com
> High Performance Clustering

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
