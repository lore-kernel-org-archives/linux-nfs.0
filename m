From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: nfs and iptables
Date: Mon, 7 Feb 2005 22:44:04 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0502072228370.22564@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyOAR-0004Fo-F9
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 21:44:07 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyOAQ-0003mz-0Z
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 21:44:07 -0800
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id j185i4Xb022796
	for <nfs@lists.sourceforge.net>; Mon, 7 Feb 2005 22:44:04 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id j185i4eg022792
	for <nfs@lists.sourceforge.net>; Mon, 7 Feb 2005 22:44:04 -0700
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


after finally solving our client reboot lockd recovery issues (as per the nfs
faq and note about muti-homed clients needing statd hostname set : note to
self - rtfm) we are pushing this change out to all our nodes.  as it turns out
the firewall rules we had in place previously actually do allow lockd
recovery.  i am worried about other scenarios however; does the server need to
be able to initiate connections to the client, eg. does true bi-directional
coms need to be enabled?  our lock recovery seems to work without this but what else
might not?

in summary: we allow *any* incoming connection to our server(s) from clients
on the backdoor (nfs on backdoor only); do we need anything special on any of
the clients or is all communication initiated from the client?

kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
