From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: We got a logfile!
Date: Wed, 08 Sep 2004 13:25:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413EEC39.10804@bio.ifi.lmu.de>
References: <413EB5A4.9040505@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C50aC-0001YK-Ec
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 04:25:48 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C50aB-0007Ca-Iy
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 04:25:48 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 572AE4358E
	for <nfs@lists.sourceforge.net>; Wed,  8 Sep 2004 13:25:46 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 4F75743583
	for <nfs@lists.sourceforge.net>; Wed,  8 Sep 2004 13:25:46 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <413EB5A4.9040505@bio.ifi.lmu.de>
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

Hi,

while the proc-debugging was still on, we rebooted a few more clients
from the old to the new kernel version and the server froze again.
Maybe the logs (if the server was able to write them far enough before
freezing) allow someone to debug the problem?

I've put them here:
http://www.bio.ifi.lmu.de/~steiner/nfsserver-freeze-log-messages.txt.bz2
http://www.bio.ifi.lmu.de/~steiner/nfsserver-freeze-procdebug.txt.bz2

The first of the clients booted on 10:39, the last one was turned-off
over night (running an old kernel before) and got up at 10:49. The
nfsserver-freeze-log-messages.txt contains the lines from /var/log/messages
between 10:39 and 10:50 (the crash time), the nfsserver-freeze-procdebug.txt
contains the kernel messages from that timeslice.
The file with the kernel messages has 1.5 million lines *urgh*, but
maybe some expert just needs to take a look at the last few entries
to see the problem...?

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
