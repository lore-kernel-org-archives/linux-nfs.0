From: "Kapil Maheshwari" <kapil_maheshwari@persistent.co.in>
Subject: help
Date: Sat, 18 Aug 2007 11:05:32 +0530
Message-ID: <001901c7e159$9863e150$ef58580a@persistent.co.in>
References: <mailman.274497.1187370904.21973.nfs@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IMJwx-00062g-Nn
	for nfs@lists.sourceforge.net; Sat, 18 Aug 2007 01:46:28 -0700
Received: from outgoing.persistent.co.in ([202.54.11.87]
	helo=bmapps.persistent.co.in)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IMJx0-0004iK-FN
	for nfs@lists.sourceforge.net; Sat, 18 Aug 2007 01:46:32 -0700
Received: from bmapps.persistent.co.in (unknown [127.0.0.1])
	by bmapps.persistent.co.in (Symantec Mail Security) with ESMTP id
	F05E752ADC4
	for <nfs@lists.sourceforge.net>; Sat, 18 Aug 2007 11:04:37 +0530 (IST)
Received: from mail.persistent.co.in (unknown [10.78.0.1])
	by bmapps.persistent.co.in (Symantec Mail Security) with ESMTP id
	BC2784E4002
	for <nfs@lists.sourceforge.net>; Sat, 18 Aug 2007 11:04:37 +0530 (IST)
In-Reply-To: <mailman.274497.1187370904.21973.nfs@lists.sourceforge.net>
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



-----Original Message-----
From: nfs-bounces@lists.sourceforge.net
[mailto:nfs-bounces@lists.sourceforge.net] On Behalf Of
nfs-request@lists.sourceforge.net
Sent: Friday, August 17, 2007 10:45 PM
To: nfs@lists.sourceforge.net
Subject: NFS Digest, Vol 15, Issue 71

Send NFS mailing list submissions to
	nfs@lists.sourceforge.net

To subscribe or unsubscribe via the World Wide Web, visit
	https://lists.sourceforge.net/lists/listinfo/nfs
or, via email, send a message with subject or body 'help' to
	nfs-request@lists.sourceforge.net

You can reach the person managing the list at
	nfs-owner@lists.sourceforge.net

When replying, please edit your Subject line so it is more specific
than "Re: Contents of NFS digest..."


Today's Topics:

   1. StreamCorruptedException Urgent. (Ignatius Pradeep Kumar Joseph)
   2. Re: [PATCH] nfsstat: without option nfsstat always output the
      statistics of Client NFS v4( though sometimes they are all zero)
      (david m. richter)
   3. [PATCH] nfsstat: update manpage for --since (david m. richter)
   4. Re: [PATCH] 64 bit ino support for NFS server (J. Bruce Fields)
   5. Re: StreamCorruptedException Urgent. (Chuck Lever)


----------------------------------------------------------------------

Message: 1
Date: Fri, 17 Aug 2007 18:46:39 +0530
From: "Ignatius Pradeep Kumar Joseph"
	<IgnatiusPradeep_Joseph@mindtree.com>
Subject: [NFS] StreamCorruptedException Urgent.
To: <nfs@lists.sourceforge.net>
Message-ID:
	<9AE21525342E4C4F8ECDC61B978843BD03823274@mtw01ex02.mindtree.com>
Content-Type: text/plain; charset="us-ascii"

Hi,

 

We are facing the following issue "StreamCorruptedException", when we are
writing large files into NFS directory. The report we were trying to run was
of 41MB size. 

When we un-mount the NFS and write the large file directly to the
application
server directly, we don't face any issues. For the moment, in order to make
the CAT successful, we have un-mounted the NFS in QA2 and set up the same in
QA3 where the stack is deployed. 

 

But we have to test these reports with the NFS before we can release it to
other environments. Please help us in finding why this issue is only
happening when we are using NFS.

 

See below part of the stack trace. From our end we are also looking at
various forums to resolve this issue. 

 

2007-06-20 01:00:03,773 [service_SessionDataService-1.0] INFO
[platform.session.PlatformSessionHelper]  - end : invokeAppSessionServices()


2007-06-20 01:02:13,925 [service_ReportGeneratorService-1.0] ERROR
[common.helper.Timer]  - Report Staticstics:Total time taken to fill the
report is  :2.7473166 mins: :: 164839.0 millies 

2007-06-20 01:02:13,925 [service_ReportGeneratorService-1.0] ERROR
[jasper.printer.PDFReportPrinter]  - After invoking
JasperFillManager.fillReport

2007-06-20 01:02:13,926 [service_ReportGeneratorService-1.0] ERROR
[jasper.printer.PDFReportPrinter]  - Before invoking exporter.exportReport()

2007-06-20 01:02:19,589 [service_ReportGeneratorService-1.0] ERROR
[engine.fill.JRAbstractLRUVirtualizer]  - Error devirtualizing object

java.io.StreamCorruptedException: invalid stream header

            at
java.io.ObjectInputStream.readStreamHeader(ObjectInputStream.java:737)

            at java.io.ObjectInputStream.<init>(ObjectInputStream.java:253)

            at
net.sf.jasperreports.engine.fill.JRAbstractLRUVirtualizer.readData(JRAbstrac
t
LRUVirtualizer.java:510)

            at
net.sf.jasperreports.engine.fill.JRSwapFileVirtualizer.pageIn(JRSwapFileVirt
u
alizer.java:112)

            at
net.sf.jasperreports.engine.fill.JRAbstractLRUVirtualizer.requestData(JRAbst
r
actLRUVirtualizer.java:401)

            at
net.sf.jasperreports.engine.base.JRVirtualPrintPage.ensureVirtualData(JRVirt
u
alPrintPage.java:312)

            at
net.sf.jasperreports.engine.base.JRVirtualPrintPage.getElements(JRVirtualPri
n
tPage.java:304)

            at
net.sf.jasperreports.engine.export.JRPdfExporter.exportPage(JRPdfExporter.ja
v
a:553)

 

Appreciate your help.

 

Regards,

Pradeep.

 



DISCLAIMER:
This message (including attachment if any) is confidential and may be
privileged. Before opening attachments please check them for viruses and
defects. MindTree Consulting Limited (MindTree) will not be responsible for
any viruses or defects or any forwarded attachments emanating either from
within MindTree or outside. If you have received this message by mistake
please notify the sender by return  e-mail and delete this message from your
system. Any unauthorized use or dissemination of this message in whole or in
part is strictly prohibited.Please note that e-mails are susceptible to
change and MindTree shall not be liable for any improper, untimely or
incomplete transmission.
E-mail may contain viruses. Before opening attachments please check them for
viruses and defects. While MindTree Consulting Limited (MindTree) has put in
place checks to minimize the risks, MindTree will not be responsible for any
viruses or defects or any forwarded attachments emanating either from within
MindTree or outside. 
-------------- next part --------------
An HTML attachment was scrubbed...

------------------------------

Message: 2
Date: Fri, 17 Aug 2007 11:04:29 -0400 (EDT)
From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [NFS] [PATCH] nfsstat: without option nfsstat always
	output the statistics of Client NFS v4( though sometimes they are
all
	zero)
To: chuli <chul@cn.fujitsu.com>
Cc: nfs@lists.sourceforge.net
Message-ID: <Pine.BSO.4.64.0708171056030.32037@citi.umich.edu>
Content-Type: TEXT/PLAIN; charset=US-ASCII

> Hi,
> 
>    There is a bug when using nfsstat without options, the Client NFS 
> v4's statistics always are output.
>     Actually it should be output when they are all zero.
>     I looked up into the code and found it says "NFSv4 call counts ([0] 
> == 32)", but it is 35 in "/proc/net/rpc/nfs".

	hello,

	good eyes -- those extra calls are getacl, setacl, and 
fs_locations counts.  it's already been fixed in the git tree at 
git://linux-nfs.org/nfs-utils.


	cheers,

	d
	.



------------------------------

Message: 3
Date: Fri, 17 Aug 2007 12:50:42 -0400 (EDT)
From: "david m. richter" <richterd@citi.umich.edu>
Subject: [NFS] [PATCH] nfsstat: update manpage for --since
To: Neil Brown <neilb@suse.de>
Cc: nfs@lists.sourceforge.net
Message-ID: <Pine.BSO.4.64.0708171247130.32037@citi.umich.edu>
Content-Type: TEXT/PLAIN; charset=US-ASCII

	Add -S/--since to the manpage with a couple examples.

---
	Hello, Neil -- here's the manpage stuff.  I'm not so sure about 
the "Examples" additions, though.. meh.  thanks, d.

 utils/nfsstat/nfsstat.man |   41 ++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index 5d2acc5..6908b06 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -72,8 +72,27 @@ Display all of the above facilities.
 .B \-v, \-\-verbose
 This is equivalent to \fB\-o all\fR.
 .TP
+.BI "\-S, \-\-since " file
+Instead of printing current statistics,
+.B nfsstat
+imports statistics from
+.I file
+and displays the difference between those and the current statistics.
+Valid input
+.IR file "s may be in the form of "
+.B /proc/net/rpc/nfs
+(raw client stats),
+.B /proc/net/rpc/nfsd
+(raw server stats), or saved output from
+.B nfsstat
+itself (client and/or server stats).   Any statistics missing from a saved
+.B nfsstat
+output
+.I file
+are treated as zeroes.
+.TP
 .B \-Z, \-\-sleep
-Instead of printing statistics and immediately exiting,
+Instead of printing current statistics and immediately exiting,
 .B nfsstat
 takes a snapshot of the current statistics and pauses until it receives
 .B SIGINT
@@ -81,6 +100,7 @@ takes a snapshot of the current statisti
 .BR Ctrl-C ),
 at which point it takes another snapshot and displays the difference
 between the two.
+.\" --------------------- EXAMPLES -------------------------------
 .SH EXAMPLES
 .TP
 .B nfsstat \-o all \-234
@@ -97,6 +117,25 @@ Show statistics for \fBNFS\fR version 3
 .TP
 .B nfsstat \-m
 Show information about mounted \fBNFS\fR filesystems.
+.TP
+.B nfsstat -v >/tmp/stats; run_short_test.sh; nfsstat -v --since /tmp/stats
+Show statistics collected while a user's
+.B run_short_test.sh
+ran.
+.P
+.RE 3
+.nf
+.B run_long_test.sh &
+.B watch -n 5 eval 'nfsstat -4 --since /tmp/stats; nfsstat -4 >/tmp/stats'
+.fi
+.RS
+Using
+.BR watch (1),
+show updates every 5 seconds of NFSv4 activity being tested by a user's
+.B run_long_test.sh
+script.
+.RE
+
 .\" --------------------- DISPLAY --------------------------------
 .SH DISPLAY
 The \fBFlags\fR output from the \fB\-m\fR option is the same as the
-- 
1.4.4



------------------------------

Message: 4
Date: Fri, 17 Aug 2007 12:51:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] 64 bit ino support for NFS server
To: Peter Staubach <staubach@redhat.com>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton
	<akpm@linux-foundation.org>,	NFS List <nfs@lists.sourceforge.net>
Message-ID: <20070817165122.GC28529@fieldses.org>
Content-Type: text/plain; charset=us-ascii

On Thu, Aug 16, 2007 at 12:10:07PM -0400, Peter Staubach wrote:
> Attached is a new patch which should address the issues raised
> by Bruce.

Thanks!

> I also haven't come to any conclusions regarding the value of
> lease_get_mtime() and whether it should or should not be invoked
> by fill_post_wcc() too.  I chose not to change this because I
> thought that it was safer to leave well enough alone.  If we
> decide to make a change, it can be done separately.

OK.

Only superficial complaints:
	- There were some minor whitespace oddities; running the patch
	  through scripts/checkpatch.pl may be the quickest way to catch
	  those.
	- This would be better as two, maybe three separate patches;
	  e.g.  moving the lease_get_mtime out of encode_fattr3 could be
	  done separately first.  Ideally we'd do some trivial
	  transformations like that, followed by one change that
	  actually changes the inode behavior.  That makes the whole
	  thing trival to review.

I fixed up the first and added the result to

	git://linux-nfs.org/~bfields/linux.git for-mm

so it should show up in the next -mm.  I'd happily replace it by a more
finely split up version if that was something you could whip up in a few
minutes.

--b.



------------------------------

Message: 5
Date: Fri, 17 Aug 2007 12:07:43 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] StreamCorruptedException Urgent.
To: Ignatius Pradeep Kumar Joseph
	<IgnatiusPradeep_Joseph@mindtree.com>
Cc: nfs@lists.sourceforge.net
Message-ID: <46C5C7CF.5040600@oracle.com>
Content-Type: text/plain; charset="windows-1252"

Ignatius Pradeep Kumar Joseph wrote:
> We are facing the following issue ?StreamCorruptedException?, when we 
> are writing large files into *NFS* directory. The report we were trying 
> to run was of 41MB size.
> 
> When we un-mount the NFS and write the large file directly to the 
> application server directly, we don?t face any issues. For the moment, 
> in order to make the CAT successful, we have un-mounted the NFS in QA2 
> and set up the same in QA3 where the stack is deployed.
> 
>  
> 
> But we have to test these reports with the NFS before we can release it 
> to other environments. Please help us in finding why this issue is only 
> happening when we are using NFS.
> 
>  
> 
> See below part of the stack trace. From our end we are also looking at 
> various forums to resolve this issue.

Hello-

The Exception message you posted is generated entirely within your Java 
environment.  Your problem description is very specific to your 
environment and application.  You need to debug your Java application 
first to determine what exactly NFS is doing to trigger this issue.

Without a lot of domain expertise, I suggest you start with strace to 
find out what system calls your application uses, and what return codes 
they generate, as your application encounters the error.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: chuck.lever.vcf
Type: text/x-vcard
Size: 290 bytes
Desc: not available

------------------------------

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/

------------------------------

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


End of NFS Digest, Vol 15, Issue 71
***********************************


DISCLAIMER
==========
This e-mail may contain privileged and confidential information which is the property of Persistent Systems Pvt. Ltd. It is intended only for the use of the individual or entity to which it is addressed. If you are not the intended recipient, you are not authorized to read, retain, copy, print, distribute or use this message. If you have received this communication in error, please notify the sender and delete all copies of this message. Persistent Systems Pvt. Ltd. does not accept any liability for virus infected mails.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
