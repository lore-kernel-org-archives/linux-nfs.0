From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] sanitize logging subsystem
Date: Sat, 19 Mar 2005 11:01:55 -0500
Message-ID: <423C4CF3.6090106@RedHat.com>
References: <200503111518.29792.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DCgHU-0005Ff-EV
	for nfs@lists.sourceforge.net; Sat, 19 Mar 2005 07:54:28 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DCgHT-00051V-1F
	for nfs@lists.sourceforge.net; Sat, 19 Mar 2005 07:54:28 -0800
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200503111518.29792.vda@ilport.com.ua>
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

Denis Vlasenko wrote:
> Patch does not introduce behavioral changes except for
> making foregrounded mountd to really use stderr.
> There was a bug which prevented this.
hmm... I've always found that if a daemon lives
in background, that the best place to debug it...

steved.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
