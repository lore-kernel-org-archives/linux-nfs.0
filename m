From: "Mock, JV Jason @ IS" <Jason.V.Mock@L-3Com.com>
Subject: NFS Caching / Locking
Date: Thu, 2 Aug 2007 12:42:39 -0500
Message-ID: <F31FEAB987B7C2469181758C14265CFA040BBABB@gvlexch03.is.l-3com.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGehD-0006Js-Qs
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 10:42:48 -0700
Received: from smtpout4.l-3com.com ([166.20.84.214])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGehG-0002fe-IQ
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 10:42:51 -0700
Received: from gvlmailhub.gvl.is.l-3com.com (gvlmailhub.gvl.is.l-3com.com
	[138.254.134.153])
	by isdns.is.l-3com.com  with ESMTP id l72HgiDX021909
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 12:42:44 -0500
Received: from gvlexch03.is.l-3com.com (gvlexch03.is.l-3com.com
	[138.254.134.123])
	by gvlmailhub.gvl.is.l-3com.com (8.13.1/8.13.1) with ESMTP id
	l72HgcNa024430
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 12:42:39 -0500
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

We've got a few problems, which I'd like to explain, that we need some
suggestions on methods of correction.  The first being caching where
client machines would see changes to a written file anywhere from 5 to
60 seconds later.  The clients are running RHEL4 (2.6.9-32 with
nfs-utils 1.0.6 - yea yea... I know... ancient...).  I know that
O_DIRECT can help override the caching, however some of the worst
effects appear to be with command line calls where we don't have the
ability/time to modify how they open files.  Just to try to get another
point of data to work with, we've loaded up 2.6.22.1 with nfs-utils
1.0.8 (and additionally tried 1.1.0), and we appear to be having less
problems except for a few occasional delays with executed commands and
are not able to view locks on all machines (locks are only visible on
the system that locked the file).  We have no problem using either
kernel, but we'd love to try to figure out each of these problems.  I
read through the NFS.sourceforge.net page the comment that "attribute
caching" and "data caching" are two seperate things.  In that context
they recommended O_DIRECT to resolve data caching, however is there any
kind of flag that we can flip to say do not cache data?  At least
2.6.22.1 is some what of an improvement on the caching...  if we could
just resolve the locking issues... would anyone have suggestions on
where to look to correct that?  I don't mind getting the NFS calls
themselves and the code if need be...
 
I do appreciate any direction that anyone can give!!
 
Jason V. Mock
Software Engineer II
L-3 Communications - Greenville Integrated Systems
Jason [DOT] V [DOT] Mock [AT] L-3Com [DOT] com

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
