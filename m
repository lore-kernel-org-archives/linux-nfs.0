From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: debugging hanging locks
Date: Tue, 17 Aug 2004 19:49:50 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408171943380.16703@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
 <1092702159.11722.77.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0408161846440.5649@harp.ngdc.noaa.gov>
 <1092757186.4030.11.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0408171146190.12428@harp.ngdc.noaa.gov>
  <1092765798.4030.59.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0408171718050.12428@harp.ngdc.noaa.gov>
 <1092789637.9393.19.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxFab-000093-8U
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 18:50:09 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BxFaa-00055f-Ny
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 18:50:09 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092789637.9393.19.camel@lade.trondhjem.org>
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

On Tue, 17 Aug 2004, Trond Myklebust wrote:

> ...but are you seeing it with a recent 2.4 kernel (2.4.26 or 2.4.27)?

yes: 2.4.21-15.0.4.EL

> The test you are providing would trigger precisely the race that was
> supposed to be fixed by patch I sent you. AFAICS that patch has not been
> applied to the 2.4.21-15 source tree.

o.k. then - good to confirm.  i'll have to wait for the patch - our sysads run
only rpms from up2date... ;-(

gotta wonder why we are paying redhat when the enterprise version moves so
slowly - two months ago i found a bug in mmap that caused kernel panic -
ugggh.

so - one more tidbit that's really odd.  when i saw the hang before not only
had none of the processes exited uncleanly - they had not exited at all!  eg.
i had many processes humming along, getting and releasing a lock on an empty
file (used as a semaphore file), when suddenly none could get the lock... this
is very strange indeed...

i guess i will just have to wait until the problem arises again, hopefully the
info you've given me about determiniing which processes have locks will come
in handy.  thanks for all the asistance again.

cheers.

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
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
