From: Olaf Kirch <okir@suse.de>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp operation
Date: Tue, 1 Mar 2005 10:55:48 +0100
Message-ID: <20050301095548.GJ14402@suse.de>
References: <20050226082854.2a496ec3@be.back.l8r.net> <20050228100633.GA4822@suse.de> <20050228102307.3788a184@be.back.l8r.net> <20050228154455.GS4822@suse.de> <20050228112018.34fdeb2b@be.back.l8r.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D646h-0008F2-1Z
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 01:55:59 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D646f-00012w-BK
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 01:55:58 -0800
To: Brad Barnett <lists@L8R.net>
In-Reply-To: <20050228112018.34fdeb2b@be.back.l8r.net>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, Feb 28, 2005 at 11:20:18AM -0500, Brad Barnett wrote:
> I start a long and extensive cp -a process on the nfs server.  Local 'ls'
> responses are instant.  Write and read operations are instant (it's a raid
> 10) on the local box, as well.  However, my single remote client's "ls"
> operation changes to a jerky, slow operation.. with upwards of 5 second
> pauses in reads.

Are you using NFS over UDP? If you ping the server from the client, do
the round trip time and packet loss rate change when you start the
heavy IO jobs on the server?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
