From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Mon, 6 Sep 2004 11:47:07 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16699.49563.188086.126554@cse.unsw.edu.au>
References: <4124DB86.9060505@steeleye.com>
	<16677.22269.988036.787320@cse.unsw.edu.au>
	<412E1C10.5020703@steeleye.com>
	<20040827073049.GA23324@suse.de>
	<412F3362.5040707@steeleye.com>
	<20040830082510.GD28454@suse.de>
	<1094196525.2283.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>,
    Paul Clements <paul.clements@steeleye.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C48bN-0006yZ-Ua
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 18:47:25 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C48bN-0008RY-G5
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 18:47:25 -0700
To: Kedar Sovani <kedars@hotpop.com>
In-Reply-To: message from Kedar Sovani on  September 3
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

On  September 3, kedars@hotpop.com wrote:
> NFS Server keeps state about the recent responses given to the clients,
> in a reply cache.
> 
> Shouldn't that state be replicated to the failed-over NFS server as well
> ?

The reply cache is an optimisation and cannot be relied upon.  Coping
it across in a fail-over would be both very expensive (it is highly
volatile) and of little benefit.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
