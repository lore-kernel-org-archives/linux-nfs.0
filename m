From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Re: more on silly names
Date: Mon, 6 Sep 2004 12:12:01 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409061206560.10600@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0409041610230.17016@harp.ngdc.noaa.gov>
 <1094338737.13791.15.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0409041813340.17016@harp.ngdc.noaa.gov>
 <1094344893.13791.68.camel@lade.trondhjem.org> <Pine.LNX.4.60.0409041924010.17016@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4NyM-0004ST-NL
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 11:12:10 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C4NyM-0007OJ-0e
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 11:12:10 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <Pine.LNX.4.60.0409041924010.17016@harp.ngdc.noaa.gov>
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

On Sat, 4 Sep 2004, Ara.T.Howard wrote:

> o.k.  here is the complete strace from the relevant bit (not very long i
> promise) with some annotations by me.  executing this code from ONE client
> will cause a silly file to be created - though it eventuall dissapears (the
> next time this code runs i think).  here is the strace:
<snip strace>

i've added a bit of code that detects all the existing sillynames before that
bit of code it run, determines those that exist after, and then removes any
new sillynames (those created by that code).  my understanding of the way
sillynames work is that if any process still required them at the time of
removal that they would pop back into existence - however, they do not.  so,
at this point, i'm 100% convinced that

   - the sillyname is created somewhere in the strace i posted

   - the sillyname is actually some sort of artifact since removing it after
     that code bit does not result in a new one being created

this still leaves me very perplexed as to the cause of sillyname in the first
place.  any opinions (based on the strace) if this is likely due to a bug in
sqlite or the nfs code base?

kind regards.

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
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
