From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 17:16:32 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402261710170.28943-100000@kenzo.iwr.uni-heidelberg.de>
References: <32952.207.214.87.84.1077802844.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>,
        ShantanuGoel <sgoel01@yahoo.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwODg-0005u3-M6
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 08:18:40 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwNxt-0005AQ-2m
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 08:02:21 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <32952.207.214.87.84.1077802844.squirrel@webmail.uio.no>
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

On Thu, 26 Feb 2004 trond.myklebust@fys.uio.no wrote:

> To simply assert that "async" is somehow equivalent to "not important" is
> just plain wrong.

That was the point of the userland modifiable ratio. Then userland can 
decide what is more important...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
