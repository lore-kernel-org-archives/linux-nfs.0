From: Justin <listuser@numbnuts.net>
Subject: NFS, Berkley mailboxes, locking, and corruption
Date: Sat, 31 Jan 2004 21:23:34 -0600 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0401312058440.23263-100000@poplar.sktc.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1An8Cu-0006JG-8s
	for nfs@lists.sourceforge.net; Sat, 31 Jan 2004 19:23:36 -0800
Received: from poplar.sktc.net ([64.71.97.16])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1An8Ct-0007ZV-RN
	for nfs@lists.sourceforge.net; Sat, 31 Jan 2004 19:23:35 -0800
Received: from poplar.sktc.net (localhost.localdomain [127.0.0.1])
	by poplar.sktc.net (8.12.6/8.12.6) with ESMTP id i113NYlk024305
	for <nfs@lists.sourceforge.net>; Sat, 31 Jan 2004 21:23:34 -0600
Received: from localhost (listuser@localhost)
	by poplar.sktc.net (8.12.6/8.12.6/Submit) with ESMTP id i113NYMV024302
	for <nfs@lists.sourceforge.net>; Sat, 31 Jan 2004 21:23:34 -0600
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

I've got a potential NFS disaster waiting to happen.  Let me describe the 
problem.

I've been tasked with setting up two new mail servers.  These boxes are
supposed to offer redundant mail server processes.  Inbound and outbound
SMTP as well as POP and IMAP.  The userbase is the same.  Both boxes
handle the mail for the set of domains.  A 3rd box is being considered for
use as a NFS server to export the mail volume.  Every single Sendmail
(actually mail in general) say to never mix mail delivery and NFS due to
locking problems.  I've experienced this myself, personally.  Setting up
backup MXs or outbound SMTP servers is a piece of cake.  The question is
how do you offer POP/IMAP access to the same userbase and the same mail
spools?  Our current setup is a common Sendmail environment using
MIMEDefang w/ ClamAV for AV filtering and SpamAssassin, Razor and Pyzor
for spam filtering.  Procmail is used for local delivery.  Mail spool
access is currently provided by QPopper, UW-IMAP, and Pine.  It's not a
complex setup; just a busy one.  All servers are x86 SMP Linux boxes 
running RH.

It's a perplexing problem.  I've considered using Cyrus and IMAP proxies
to accomplish this, although I don't know if that will work either.  This
still leaves a single point of failure, making the multiple server project
moot.  I'd like to migrate to Cyrus anyway, although I have no experience 
with it at this time.

Another alternative is maildir.  I know Procmail can be tricked into
writing it.  I don't believe Qpopper has support for it.  I know UW-IMAP
doesn't support it.  We have to have IMAP for webmail.  All the users use
POP with their choice of MUA.  I think MailDir would be more of a problem
in the long run unfortunately.

At this point and time it looks like NFS is what they planned on using
when they came up with this design.  I know it will "appear" to work.  I
also know that it will silently lose mail.  Making all involved understand
this very important fact is important and possibly difficult.  The mail
system currently handles 30-50k pieces of mail a day, not counting spam.  
This is busy enough to lose a lot of mail.

How badly will NFS and this type of setup lose mail or corrupt mail
spools?  We can't afford to risk the integity of our mail system, period.  
What other solutions might there be if NFS isn't a viable solution?  How
do larger institutions handle grand amounts of mail?  SAN?  Many thanks

Justin



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
