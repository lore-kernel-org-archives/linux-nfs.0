From: Thanos Chatziathanassiou <tchatzi@arx.gr>
Subject: Performance Difference based on .... ?
Date: Mon, 12 Jul 2004 20:37:08 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40F2CC44.7080104@arx.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bk4kZ-0001ZY-U1
	for nfs@lists.sourceforge.net; Mon, 12 Jul 2004 10:37:59 -0700
Received: from dev.arx.gr ([212.205.86.237] helo=www4.arx.gr)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bk4kY-0004am-QM
	for nfs@lists.sourceforge.net; Mon, 12 Jul 2004 10:37:59 -0700
Received: from arx.gr (skevos.arx.gr [212.205.86.238] (may be forged))
	by www4.arx.gr (8.9.3p3/8.9.3) with ESMTP id UAA05431
	for <nfs@lists.sourceforge.net>; Mon, 12 Jul 2004 20:37:08 +0300
To: nfs@lists.sourceforge.net
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

Hello list,

I have come to a dead-end...
How come on a freshly mounted file-system, compiling takes considerably 
less time than on subsequent runs ?
I mean, this snip of shell:
---snip---
for i in 1 2 3
do
time ./apachectl configtest
done
---snip---
2:17.23 on the first run, while it takes
3:21.92 on the second and
3:20.78 on the third run.

The network is 1gb ethernet, with jumbo frames 9000 and tests were run 
both on 4096 and 8192 rsize/wsize with more or less similar results.
Client is 2x AthlonMP 1800+, server is 2x AthlonMP 2200+, kernel on both 
is 2.4.26+Trond's linux-2.4.26.NFS.ALL patch,
mount is udp - essentially so, because this is meant to be a high 
availability setup.
The only real limitation is the rate at which the server can feed data 
to the client, since cpu is 31% on the first and 20% on the second and 
third runs.

Any ideas ? Any other info I can give that might help ?

Regards,
Thanos Chatziathanassiou



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
