From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: unexplained ESTALE
Date: Tue, 31 Aug 2004 17:24:39 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408311723210.18194@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408301629590.561@harp.ngdc.noaa.gov>
 <413506F5.3040708@RedHat.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2HzZ-0001XG-Mo
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 16:24:45 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C2HzY-0004eo-4I
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 16:24:45 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <413506F5.3040708@RedHat.com>
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

On Tue, 31 Aug 2004, Steve Dickson wrote:

> Ara.T.Howard wrote:
>
>> are there any conditions on client or server i should know about (besides 
>> the
>> obvious ones) that could cause this?
>
> Can it be assumed that autofs is not involved?

yes.

> Just to be clear, "/nfs/mounted/daemon -l logfile" does work  once
> or twice and then things go stale?

not quite - it is __working__ (started once and never exited) when it blows up
suddenly with ESTALE.  eg.  binary starts, binary runs, runs, runs - then
binary blows up (well bash reports ESTALE).

> You mentioned something about being on a cluster, has there been any
> failovers (or similar events) before things go stale?

none.

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
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
