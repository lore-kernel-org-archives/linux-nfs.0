From: Maxwell Bottiger <sleepylight@jive-turkey.net>
Subject: nfs hang, acutaully really slow
Date: Thu, 6 May 2004 15:37:17 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405061531390.4371-100000@jive-turkey.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLogP-0005BM-1n
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:37:25 -0700
Received: from sccrmhc11.comcast.net ([204.127.202.55])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLogO-0002Rp-OP
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:37:24 -0700
Received: from jive-turkey.net (localhost.localdomain [127.0.0.1])
	by jive-turkey.net (8.12.8/8.12.8) with ESMTP id i46JbHAN004394
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 15:37:17 -0400
Received: from localhost (sleepylight@localhost)
	by jive-turkey.net (8.12.8/8.12.8/Submit) with ESMTP id i46JbHHi004390
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 15:37:17 -0400
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
	I'm running some version of NFSv3.  I have whatever came packaged 
along with Fedora Core 1.  (They put their own version number on the 
package)

	My server appears to be running into a real problem transfering 
files.  As long as my transfers are super small (like ls) then everything 
is cool.  As soon as I try to work on bigger files (greater than 4k) most 
everything grinds to a screetching halt.  I can see that there is still 
activity, but the transfers are in terms of 3 or 4 packets every few 
seconds.  I've sort of been hobbling along using scp (wich is runing 
somewhere between 1000x to 1000000x faster than NFS right now) but that 
only works for so long.

	Where do I start trying to solve this problem?  I haven't been 
able to find any error messages.  Any help is greatly appreciated.

-- 
-Maxwell Bottiger
http://www.jive-turkey.net

If at first you don't succeed, redefine success.



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
