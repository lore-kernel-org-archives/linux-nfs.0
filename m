From: "UNIREA Sannicolau Mare" <credsantm1@rdslink.ro>
Subject: NFS wierd problem
Date: Mon, 1 Aug 2005 11:50:39 +0300
Message-ID: <000101c59680$d7e952e0$0101a8c0@credsantm>
References: <20050731031512.4413433D78@sc8-sf-spam1.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-2"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DzXDC-0003h4-Oj
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 03:07:58 -0700
Received: from mail.rdslink.ro ([193.231.236.20])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1DzXDB-00061J-Oe
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 03:07:58 -0700
To: <nfs@lists.sourceforge.net>
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

Ok! I have fix it somehow... it looks like this:

The server is 192.168.1.3, the client is 192.168.1.4
- the /etc/exports on the server contains:
 /scoop *(rw,sync)

- the /etc/hosts on server contains:
 CASA1 127.0.0.1 localhost.localdomain localhost
 CASA2 192.168.1.4

- the /etc/hosts.allow and /etc/hosts.deny on the server and client are all
blank!!!!

- the /etc/hosts on client contains:
 CASA2 127.0.0.1 localhost.localdomain localhost
 CASA1 192.168.1.3

When I go to client and give
 #mount 192.168.1.3:/scoop /mnt/1
it works well and I can use the /mnt/1 directory in read-write mode

Ok by now. I give on client
 #umount /mnt/1

I give on server
 #service nfs restart

I give on client:
 #mount 192.168.1.3:/scoop /mnt/1
I receive error: connection failed: the server is down

>From now one, no mater how many times I restart the nfs services on server,
the client tell's me the server is down.

If I rboot the server Linux then all will work fine again (I can mount all
stuff untill I need to restart nfs services which forces me to reboot the
server linux station)

That's a wierd problem. I'm using Fedora Core 2 on all stations. It can be a
distribution problem.



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
