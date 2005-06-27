From: "R. Adelsberger" <xiphias@web.de>
Subject: "nfs warning: mount version older than kernel"
Date: Mon, 27 Jun 2005 15:37:00 +0200
Message-ID: <42C000FC.5080000@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DmtnW-00061V-Gq
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 06:37:14 -0700
Received: from smtp08.web.de ([217.72.192.226])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DmtnW-0007gN-23
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 06:37:14 -0700
Received: from [83.77.154.140] (helo=[192.168.1.5])
	by smtp08.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.105 #297)
	id 1DmtnN-0004Cf-00
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 15:37:06 +0200
To: nfs@lists.sourceforge.net
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

Hi!

I receive this message since I decided to mount some parts of my home
folder (via autofs) from a server.
Although I searched during several months for a solution and reviewed my
configs several times, I was not able to resolve this issue.
Could anybody tell me, where the problem lies - or, if you need more
information, tell me what I should further reveal...

My kernel (2.6 series - currently 2.6.11) on the client machine has the
nfs v3 support and the server the apropriate server support.
Nevertheless, my logfile is full of the messages mentioned in the
subject. I have the most recent (stable) version of mount installed...

Any help is apreciated :-)

Cheers, R.



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
