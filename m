From: Ragnar =?iso-8859-15?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost servers.
Date: Wed, 24 Nov 2004 18:35:25 +0100
Message-ID: <20041124173525.GI19342@vestdata.no>
References: <41A39D57.8060902@RedHat.com> <20041123232636.GE19342@vestdata.no> <41A3D9CC.7040404@RedHat.com> <20041124020017.GH19342@vestdata.no> <41A477C8.4060405@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX13I-0007K9-Dh
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 09:35:36 -0800
Received: from [217.149.127.10] (helo=stine.vestdata.no)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CX13E-0003lE-Ib
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 09:35:36 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41A477C8.4060405@RedHat.com>
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

On Wed, Nov 24, 2004 at 07:00:08AM -0500, Steve Dickson wrote:
> >If that's the case, are we allowed to just send the IP instead of the
> >name?
> >=20
> >
> No, since the spec says a the id_mon needs to be character string....

"10.0.0.1" is a character string as much as any - unless the
specification says something more about this?



> >- If you have aliases (eth0, eth0:0) with different IPs but on the
> > same network. The current patch (if I read it correctly) will then
> > use the name from the last alias, which is kind of random.
>
> Well it would not be random, it would be the first interface....
>=20
> >The second case may be very relevant to the HA-problem which "-n" was
> >originally added for.
> >=20
> >
> Yes... the -n flag wold be the answer here...

Unless, of course, a more general fix would handle this automatically.

And I think that could be something along the lines:

- loop over all available interfaces
  - for each interface, send a message to all clients that belong on
    this subnet
  - the message could be based on the IP or gethostbyaddr(IP).


In short, this is exactly like what your patch does except that:
- if there are multiple matching interfaces (e.g. aliases) we
  send messages for all
- I still don't understand why we don't send the IP instead of
  the name.


Unlike sending messages for all names to all clients it's not too
verbose.

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
