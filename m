From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: debugging hanging locks
Date: Thu, 19 Aug 2004 09:15:44 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408190913540.30300@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
 <1092702159.11722.77.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0408161846440.5649@harp.ngdc.noaa.gov>
 <1092757186.4030.11.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0408171146190.12428@harp.ngdc.noaa.gov>
  <1092765798.4030.59.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0408171718050.12428@harp.ngdc.noaa.gov>
 <1092789637.9393.19.camel@lade.trondhjem.org> <Pine.LNX.4.60.0408181413120.21641@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bxods-0006Eh-Uh
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 08:15:52 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bxods-0005Ya-I3
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 08:15:52 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <Pine.LNX.4.60.0408181413120.21641@harp.ngdc.noaa.gov>
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

On Wed, 18 Aug 2004, Ara.T.Howard wrote:

i had forgotten one very important peice of information - the pid 25111 in the
output below is not running on any host - it does not exist...

-a

> hi trond-
>
> knowing that my code can trigger this bug, i ran it all night ;-)  sure
> enough, i have a problem:
>
>  - two nodes are running the code, jib and carp
>  - the pids of the processes asking for the locks are
>
>      jib  : 4070
>      carp : 5298
>
> here is what /proc/locks look like
>
>  [root@moby root]# cat /proc/locks | grep 24969572
>
>  1: POSIX  ADVISORY  WRITE 25111 08:21:24969572 0 EOF d5f0b4c0 c03a36c8
>  d9796584 00000000 ece5a87c
>
>  1: -> POSIX  ADVISORY  WRITE 5298 08:21:24969572 0 EOF ece5a870 e42e9874
>  c03a36d0 d5f0b4c0 e42e987c
>
>  1: -> POSIX  ADVISORY  WRITE 4070 08:21:24969572 0 EOF e42e9870 c03a36d0
>  ece5a874 d5f0b4c0 d5f0b4cc
>
> the way i am interpreting this is that the '->' means those processes are
> asking for the lock.  i assume this to be correct.  my questions are
>
>  - how do i tell what host pid 25111 is running on, is this info available
>    via some file, utility, or kernel data structure some c code could 
> access?
>
>  - i KNOW there are only two process running my lock breaking code and they
>    are both hung.  is there any scheme, no matter how hackish, that either
>    client or server could detect these phantom locks and do something about
>    them?  for instance, i know that moving the file out of the way and back
>    will clear things up for future processes...
>
>  - would restarting /etc/init.d/nfslock a few times per day be a good safety
>    measure to clear things up, or would this break other things?


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
