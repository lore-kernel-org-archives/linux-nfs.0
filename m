From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: speed for NFS
Date: Tue, 27 Aug 2002 11:30:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020827113005.A6228@vestdata.no>
References: <3D6B2588.938F375E@fz-juelich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jcfv-0003uM-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 02:30:16 -0700
To: Reimar Bauer <r.bauer@fz-juelich.de>
In-Reply-To: <3D6B2588.938F375E@fz-juelich.de>; from r.bauer@fz-juelich.de on Tue, Aug 27, 2002 at 09:08:56AM +0200
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

On Tue, Aug 27, 2002 at 09:08:56AM +0200, Reimar Bauer wrote:
> Dear all,
>=20
> in the next few years we will have  much amount of
> data something about 70 - 100 TByte.
>=20
> At the moment with our configuration nfs speed is=20
> quite less against the network speed.
> I believe this could be extended and this is necessary.
>=20
> The max transfer rate we have is about 3MByte/sec.
>=20
> Is there a possibility to increase this to 30MByte/sec.
> Is this relalistic?=20
> Where can I get a description about this?=20

Yes, 30MB/s is realistic for nfs (sequantial access) - on our RAIDs
we are able to do approxemately 50-60 MB/s over NFS (gigabit ethernet).

You first need to make sure your local access is fast enough. For
nfs-access to reach 30MB/s local access must be significantly higher, as
there is some overhead in NFS. (Our RAIDs do approxemately 100-120 MB/s
locally). Increasing readahead setting might help for reads.

For configuring NFS I would start with making sure you're using NFS v3.
Next, enable jumbo-frames (if you do large transfers over gigabit
ethernet) and increase buffer-sizes.



--=20
Ragnar Kj=F8rstad
Big Storage


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
