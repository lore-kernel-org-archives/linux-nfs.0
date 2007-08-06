From: Larry Alkoff <labradley@mindspring.com>
Subject: Can't mount nfs - omething missing
Date: Sun, 05 Aug 2007 22:09:08 -0500
Message-ID: <46B690D4.8000102@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IHsxv-0000pF-6L
	for nfs@lists.sourceforge.net; Sun, 05 Aug 2007 20:09:07 -0700
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IHsxy-00034v-1v
	for nfs@lists.sourceforge.net; Sun, 05 Aug 2007 20:09:11 -0700
Received: from [24.206.107.195] (helo=[10.22.44.3])
	by elasmtp-spurfowl.atl.sa.earthlink.net with asmtp (Exim 4.34)
	id 1IHsxs-0000BP-1V
	for nfs@lists.sourceforge.net; Sun, 05 Aug 2007 23:09:04 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I am trying to mount a computer using nfs and _think_ I have all the 
necessary daemons running.

The system doing the mounting is Kubuntu Feisty 7.04.
This system has mounted several others so I presume the problem is on 
the system being mounted.

The system being mounted is a Slackware system.
On that system I have a list of exports and have run exportfs -rav.
I am running nsfd, portmap, rpc.rquotad,  mountd, statd
per ps ax.

Can anyone suggest anything that is missing?

Larry
-- 
Larry Alkoff N2LA - Austin TX
Using Thunderbird on Linux

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
