From: Steve Dickson <SteveD@redhat.com>
Subject: Re: unexplained ESTALE
Date: Tue, 31 Aug 2004 19:17:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413506F5.3040708@RedHat.com>
References: <Pine.LNX.4.60.0408301629590.561@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2HsP-0008Vs-Jk
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 16:17:21 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C2HsP-0005vj-0W
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 16:17:21 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0408301629590.561@harp.ngdc.noaa.gov>
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

Ara.T.Howard wrote:

> are there any conditions on client or server i should know about 
> (besides the
> obvious ones) that could cause this?

Can it be assumed that autofs is not involved?

Just to be clear, "/nfs/mounted/daemon -l logfile" does work  once
or twice and then things go stale?

You mentioned something about being on a cluster, has there been any
failovers (or similar events) before things go stale?

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
