From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: NFS & Clustering
Date: Wed, 4 Sep 2002 18:25:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020904182555.C1582@vestdata.no>
References: <95AF67BA7F70D511829B0002A551737001C9CB@faw-e01.faw.freudenberg.de> <1031155426.25370.2.camel@plokta.s8.com> <20020904182005.B1582@vestdata.no> <1031156560.25369.4.camel@plokta.s8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Marco.Schwarz@Freudenberg.de, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Bryan O'Sullivan" <bos@serpentine.com>
In-Reply-To: <1031156560.25369.4.camel@plokta.s8.com>; from bos@serpentine.com on Wed, Sep 04, 2002 at 09:22:40AM -0700
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

On Wed, Sep 04, 2002 at 09:22:40AM -0700, Bryan O'Sullivan wrote:
> On Wed, 2002-09-04 at 09:20, Ragnar Kj=F8rstad wrote:
>=20
> > Sure it is. mountd writes the information to disk - you just need to
> > share that info between the servers.
>=20
> That leaves you with an obvious race condition.

For active/passive systems there are no race-conditions and it works
fine. For active/active systems there would be a race, but it still
wouldn't work because the data is (AFAIK) not reread from disk.


--=20
Ragnar Kj=F8rstad


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
