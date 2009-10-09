From: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org
Subject: [NFS] NFS/krb and batch jobs - doable?
Date: Fri, 9 Oct 2009 08:15:12 -0700
Message-ID: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36052 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933451AbZJIP3t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 11:29:49 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MwHP5-0002CG-R6
	for linux-nfs@vger.kernel.org; Sat, 10 Oct 2009 02:29:11 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been struggling for some time to understand how to allow users of
long-running batch jobs to continue to do so in an environmnet migrated to
NFS4 with kerberos (from non-kerberized NFS), centered around the problem
of keeping their batch job credentials separate from login credentials,
which might otherwise mangle or delete them and cause the batch jobs to
die on logout - or say if the users opted for renewable tickets for the
job explicitly but the system default is non-renewable.

The central problem seems to be that NFS4 (on Linux at least) doesn't
support the concept of multiple sessions, and seems to expect to see a
standard ccache filename /tmp/krb5cc_${UID}.  Am I right in thinking this
is a fundamental limitation?  I've played with KRB5CCNAME but am led to
believe NFS ignores this; I've also added ccname template settings to
krb5.conf and PAM to try to fool NFS into separating batch job credentials
from user ones, but don't seem to be getting a robust separation.

The essential problem is that I need an environment where a user can
obtain credentials that may be different from the desirable interactive
default (e.g. longer duration, renewable), then run a batch job, ideally
in the heterogeneous ways they do currently - run via a shell, kicked off
on another machine via ssh, via condor - and not have its credentials at
risk if the user then logs into the machine it's running on, submits a
second job etc.

Is this doable currently?  I'm surprised (so far) to not run across people
who are doing this, and would be very surprised if it's not a requirement
for many.  If not, is it likely to be doable soon and what does it depend
on?

I can supply more technical details of what I've tried if useful.  Please
also let me know if there's a more appropriate place I can ask these
questions.  Thanks.



------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

