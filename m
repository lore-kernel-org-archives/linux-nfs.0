From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: client side noac
Date: Sat, 26 Jun 2004 16:17:06 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406261615060.10096@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
 <1088186851.4333.65.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
  <1088191021.4333.75.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
 <1088192302.4333.83.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BeLU1-0006cI-55
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 15:17:13 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BeLU0-0007EP-N0
	for nfs@lists.sourceforge.net; Sat, 26 Jun 2004 15:17:13 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1088192302.4333.83.camel@lade.trondhjem.org>
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

On Fri, 25 Jun 2004, Trond Myklebust wrote:

> open() should not cause cache flushes unless it detects that the file
> has been modified.
>
> As for whether or not lookups are cached: We check the mtime of the
> parent directory in order to find out whether or not it has changed. If
> it has, then we do a new lookup of the file.
>
> Cheers,
>  Trond

so i can see how opening a file may result in a later ESTALE (mtime caching)
but how could open ITSELF return ESTALE?  this is the behaviour i'm seeing.

confused.

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it. 
|   --Dogen
===============================================================================


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
