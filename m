From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: RE: sendmail "cannot fsync directory" after 2.4 -> 2.6
Date: Thu, 9 Sep 2004 14:36:35 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409091435560.17332@harp.ngdc.noaa.gov>
References: <482A3FA0050D21419C269D13989C61130435E7A8@lavender-fe.eng.netapp.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5Vf3-0004hQ-NU
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 13:36:53 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C5Vf2-0006ai-Uk
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 13:36:53 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E7A8@lavender-fe.eng.netapp.com>
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

On Thu, 9 Sep 2004, Lever, Charles wrote:

>>> Yep. We forgot to add the stub to Linux 2.6.x. Please
>> confirm that the
>>> following patch fixes the problem for you.
>>
>> will fsync'ing a directory have any affect on the client
>> inode cache for that dir?  eg. will it invalidate that cache?
>
> ara-
>
> looking at the patch trond posted, it appears to add a "no-op" function
> for fsyncing NFS directories.  this means fsync against an NFS directory
> will not complain, but otherwise does nothing.

yeah - i wasn't sure if that was for the client or server side.  i'm am
concerned with invalidation ot the client side cache.

thanks for the clarification.

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
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
