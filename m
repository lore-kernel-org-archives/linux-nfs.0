From: "Jim Dennis" <jdennis@cadence.com>
Subject: Testing Lab Suggestions?
Date: Thu, 9 Mar 2006 10:55:13 -0800
Message-ID: <920746F6DF728345915EF4D6DA610D0F205403@MAILSJ2.global.cadence.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHQJ1-000670-Rf
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 10:56:11 -0800
Received: from isvw3.cadence.com ([158.140.2.61] helo=mx-sanjose2.Cadence.COM)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FHQIy-00017W-R6
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 10:56:12 -0800
Received: from MAILSJ2.global.cadence.com (localhost [127.0.0.1])
	by mx-sanjose2.Cadence.COM (8.12.9/8.12.9) with ESMTP id k29Iu0QH025027
	for <nfs@lists.sourceforge.net>; Thu, 9 Mar 2006 10:56:00 -0800 (PST)
To: <nfs@lists.sourceforge.net>
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


 All,

 One of our projects here entails the creation of a test lab for
validating
 the performance and, especially, the stability of newly proposed
internal
 images.

 In the past we've done some fairly labor intensive and ad hoc
NFS/autofs
 testing.  Our organization uses (or *ABUSES*) NFS and autofs very
 heavily.  So this is one of the most important aspects of our testing.

 Therefore I'm here to solicit suggestions.

 How do we create a test environment that effectively simulates a huge
 heterogenous NFS environment (mostly NetApps, and IBM ESS but including

 lots of naughty /net to peers and other ugliness)?

 Let's assume that we don't have a huge budget but we want to simulate
about
 fifty NFS servers and about 75 different autofs maps.  Let's further
assume
 we want to simulate loading of about 250 concurrent and relatively
heavily
 loaded and powerful clients per NFS server ... the typical clients will
be
 Opteron or EM64T systems with 4 to 32GiB of RAM and 2 to 4 CPUs (which
may
 further be dual core or hyperthreaded and therefore account for 4 to 8
virtual
 CPUs).  Finally lets assume that the bulk of the workload should be
similar
 to an LSF/Condor farm ... lots of concurrent jobs on lots of hosts
triggering
 lots of concurrent automounts and file accesses, with loads of write
and
 locking activity ... most of it multi-threaded as well.

 Oh, yeah ... and this must be primarily focused on RHEL3 (2.4 based
kernel)
 and SLES9 clients --- not the more recent releases with more up-to-date
kernels.

 As usual the real question here is: are there any good scripts or tools
or even
 HOWTO docs for doing this sort of testing.  As always the challenge is
 introducing enough load on each subsystems to give a reasonable model
of how
 it'll all work in an environment that's ten to a hundred times the
scale.

 I remember trying to set up a load testing harness for web servers was
challenging
 enough --- trying to simulate the load of a few thousand web browsers
using only
 a couple dozen client hosts and include varying connection rate, cookie
handling,
 agent values, and other characteristics enough to represent anything
like a real
 load.  I'm guessing that these NFS test requirements offer even more
challenges
 in that regard.

 So .... papers?  suggestions?  HOWTOs?  scripts and tools?

JimD


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
