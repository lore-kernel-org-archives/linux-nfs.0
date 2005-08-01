From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: NFS wierd problem
Date: Mon, 01 Aug 2005 08:55:48 -0400
Message-ID: <1122900949.28132.2.camel@barsoom.rdu.redhat.com>
References: <20050731031512.4413433D78@sc8-sf-spam1.sourceforge.net>
	 <000101c59680$d7e952e0$0101a8c0@credsantm>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DzZpi-00016D-9W
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 05:55:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DzZph-0006AK-6W
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 05:55:54 -0700
To: UNIREA Sannicolau Mare <credsantm1@rdslink.ro>
In-Reply-To: <000101c59680$d7e952e0$0101a8c0@credsantm>
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

On Mon, 2005-08-01 at 11:50 +0300, UNIREA Sannicolau Mare wrote:
> - the /etc/hosts on server contains:
>  CASA1 127.0.0.1 localhost.localdomain localhost
>  CASA2 192.168.1.4
> 

If the lines in your /etc/hosts files truly look like that, then that
may be the issue. All lines in there should start with an IP address,
not with these 'CASA1/2' labels.

Apologies if I'm misinterpreting what you posted here...
-- 
Jeff Layton <jtlayton@poochiereds.net>



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
