From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: NFS & Clustering
Date: Wed, 4 Sep 2002 18:53:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020904185303.D1582@vestdata.no>
References: <95AF67BA7F70D511829B0002A551737001C9CB@faw-e01.faw.freudenberg.de> <1031155426.25370.2.camel@plokta.s8.com> <200209041824.46264.emanuel.quass@temic.com> <1031157608.25370.8.camel@plokta.s8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: emanuel.quass@temic.com, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Bryan O'Sullivan" <bos@serpentine.com>
In-Reply-To: <1031157608.25370.8.camel@plokta.s8.com>; from bos@serpentine.com on Wed, Sep 04, 2002 at 09:40:08AM -0700
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

On Wed, Sep 04, 2002 at 09:40:08AM -0700, Bryan O'Sullivan wrote:
> On Wed, 2002-09-04 at 09:24, Emanuel Quass wrote:
>=20
> > but doesn't it work if you share /var/lib/nfs/* (containing etab, rmt=
ab, sm, =20
> > sm.bak, state, xtab)?
>=20
> Not reliably.  You're left with a single point of failure, for one
> thing.  You also have races between one server permitting a mount and
> others knowing that the mount has been allowed, which can confuse
> clients.

I suppose you're suggesting that the disk with /var/lib/nfs/ is a single
point of failure? Well yes, unless you use a redundant storage-system.


The race-condition is only present when the nfs-service is enabled on
both server at the same time. For active/passive failover you have
software that monitor the health of the the primary-system and the
secondary system is only started up if the primary fails. So, there is
no race.



--=20
Ragnar Kj=F8rstad


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
