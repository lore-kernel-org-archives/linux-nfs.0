From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: NFS & Clustering
Date: 04 Sep 2002 09:22:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1031156560.25369.4.camel@plokta.s8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Marco.Schwarz@Freudenberg.de, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Ragnar =?ISO-8859-1?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
In-Reply-To: <20020904182005.B1582@vestdata.no>
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

On Wed, 2002-09-04 at 09:20, Ragnar Kj=F8rstad wrote:

> Sure it is. mountd writes the information to disk - you just need to
> share that info between the servers.

That leaves you with an obvious race condition.

	<b


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
