From: Batara Kesuma <bkesuma@ml.gaijinweb.com>
Subject: NFS bottleneck
Date: Mon, 6 Sep 2004 11:18:52 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040906111852.6cb9e1b7.bkesuma@ml.gaijinweb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C491v-000637-1U
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 19:14:51 -0700
Received: from skylab.gaijinweb.com ([219.106.230.75])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C491u-0003kR-7R
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 19:14:50 -0700
Received: from wolverine (unknown [219.106.230.78])
	by skylab.gaijinweb.com (Postfix) with SMTP id 024A0FE89D
	for <nfs@lists.sourceforge.net>; Mon,  6 Sep 2004 11:14:44 +0900 (JST)
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

Hi,
I am running an NFS server for image files. This NFS server is connected
to 2 web servers dedicated to serve image files. The specs of this NFS
server:
P4 2.80GHz (with HT)
1GB RAM
250GB HDD SATA RAID 1
kernel-smp-2.6.5-1.358

My web site has about 4 million pageview/day, each page has about 10
images, so it is about 40 million access to the image files (NFS
server). There is more read than write. Maybe about 1000 to 1.

When the traffic is high, I noticed that the response of the NFS server
was very slow. I checked with top and the load average was around 8. Is
there anything I can do to speed it up? Will it help a lot if I change
the HDD to faster one (SCSI with RAID 5)? Anybody has same experience?
Thank you very much.

Regards,
Batara


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
