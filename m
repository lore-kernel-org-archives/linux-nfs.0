From: "Alexander Povolotsky" <pevnev@juno.com>
Subject: NFS  Server effect in performance CPU benchmarking  on diskless NFS cl
 ients ?
Date: Thu, 21 Oct 2004 20:56:35 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041021.135736.504.125611@webmail02.lax.untd.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKk1Z-00019T-QA
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 13:59:05 -0700
Received: from outbound-mail.lax.untd.com ([64.136.28.164])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CKk1X-0001sT-W8
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 13:59:05 -0700
Received: from outbound29-sr.lax.untd.com (webmail02.lax.untd.com [10.131.27.142])
	by smtpout01.lax.untd.com with SMTP id AABAZSJZFA32XU3S
	for <nfs@lists.sourceforge.net> (sender <pevnev@juno.com>);
	Thu, 21 Oct 2004 13:58:13 -0700 (PDT)
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


On diskless embedded boards with NFS mounted root file system
(from where the tests are launched and to where the tests results are going for "collection")  - the absolute value of test results are "contaminated"  (affected) by the performance of the 
'external' NFS server,  which hosts root NFS file system, on which my diskless board mounts.

Is there any methodology for adjusting diskless nfs clients CPU performance benchmark results with regards to the effect of latencies caused by the NFS server ?


________________________________________________________________
Speed up your surfing with Juno SpeedBand.
Now includes pop-up blocker!
Only $14.95/ month - visit http://www.juno.com/surf to sign up today!


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
