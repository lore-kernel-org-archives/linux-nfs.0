From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client side noac
Date: Mon, 28 Jun 2004 00:37:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088397445.4295.51.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
	 <1088186851.4333.65.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
	 <1088191021.4333.75.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
	 <1088192302.4333.83.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406261615060.10096@harp.ngdc.noaa.gov>
	 <1088364509.4295.14.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406272148170.31370@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BentY-0000xz-JW
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 21:37:28 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BentX-00041B-VE
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 21:37:28 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406272148170.31370@harp.ngdc.noaa.gov>
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

P=E5 su , 27/06/2004 klokka 23:55, skreiv Ara.T.Howard:

> i understand what you are saying.  i guess i should clarify by saying "i =
don't
> understand _why_ open itself should return ESTALE".  i mean, in the case =
of a
> read or write the client cannot know what action to take.  in this case i=
t
> seems like the client certainly can: make an RPC call.  i realize the des=
ign
> emphsizes making the minumum number of calls, but this seems like one too=
 few
> doesn't it?  i really don't know the code at all so please forgive me if =
this
> sounds stupid: but why, upon finding a statle filehandle, is it deemed be=
tter
> to return this known bad value instead of checking for a newer (and still
> possibly bad) one?  are there certain conditions which warrant this behav=
iour?
>=20
> more to the point, this is what i'm doing in my code
>=20
>    fd =3D
>      begin
>        open path
>      rescue Errno::ESTALE
>        open path
>      end
>=20
> in otherwords - if ESTALE is found on open, try once more.  this seems to
> work.  should i not be doing this?  if i should, why shouldn't the nfs cl=
ient
> code do it for me?

In 2.6.x kernels, we don't do strict revalidation of the parent
directories in the path: only the target file itself, so if someone
deletes the current directory, you may end up with a stale filehandle.
Please also note that renaming directories (and files) into other
directories is also prone to this sort of ESTALE errors if your Linux
server isn't exporting using the "no_subtree_check".

Otherwise, the file itself should always be strictly checked (unless
you've also got the "nocto" mount flag set). I won't exclude that the
lookup may be using stale data if there turns out to be some race with
readdirplus on NFSv3 that we've overlooked. You could check by comparing
with a NFSv2 mount.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
