From: Doug Lee <douglee@arsene.com.tw>
Subject: NFS mount problem on Linux 2.4.20
Date: Mon, 17 May 2004 23:00:55 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040517230055.GB19701@arsene.arsene.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPjY2-0002rA-Rr
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 07:56:58 -0700
Received: from 61-222-117-227.hinet-ip.hinet.net
	([61.222.117.227] helo=arsene.arsene.com.tw ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BPjY1-00057G-PM
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 07:56:58 -0700
Received: from arsene.arsene.com.tw (douglee@localhost.arsene.com.tw [IPv6:::1])
	by arsene.arsene.com.tw (8.12.9/8.12.9) with ESMTP id i4HN0v96031220
	for <nfs@lists.sourceforge.net>; Mon, 17 May 2004 23:00:59 GMT
Received: (from douglee@localhost)
	by arsene.arsene.com.tw (8.12.9/8.12.9/Submit) id i4HN0uSD001960
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 23:00:56 GMT
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

I'm using Linux 2.4.20 without any patches for both nfs server and 
client machine. On server side, I have one big file, which size is 9GB.
On client, when I mount, that file only is about 500MB.
I try to use Fedora Core 1 and Debian as nfs clients, the result is the same.
Would anyone tell me how to solve this issue? Or should I patch which
diff? Thanks.

Regards,
Doug.


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
