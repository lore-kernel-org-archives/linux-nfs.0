From: "Jocky Wilson" <jocky_wilson@hotmail.com>
Subject: rsize, wsize > 32Kb : how?
Date: Thu, 09 Dec 2004 23:48:07 +0000
Message-ID: <BAY21-F16DEBCC035FC2844261BF6E4B70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcY26-00036f-7q
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 15:49:14 -0800
Received: from bay21-f16.bay21.hotmail.com ([65.54.233.105] helo=hotmail.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CcY22-0001hn-LV
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 15:49:12 -0800
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

Hi,

I compiled NFS utils 1.0.6 for my Asus WL-HDD NAS device and I compiled the 
2.4.27 kernel with support for up to 64Kb values (const.h: NFSSVC_MAXBLKSIZE 
65536). It all works pretty good, but unfortunately if I try mounting with 
rsize/wsize >32Kb the mount is always rsize=wsize=32Kb. I'm quite keen to 
mount with larger wsize/rsize values as I expect better performance. How can 
I accomplish larger rsize/wsize values?

Cheers,
JockyW

PS: for mounting I use mount from busybox 1.0.0




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
