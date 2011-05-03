From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: messages on restarting NFS
Date: Tue, 3 May 2011 02:30:17 -0700 (PDT)
Message-ID: <348580.13472.qm@web111713.mail.gq1.yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: nfs <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nm6-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.206]:32149 "HELO
	nm6-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752003Ab1ECJaS convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2011 05:30:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
When I restart NFS with=20


/etc/init.d/nfs-kernel-server restart


I see these messages in syslog:

May=A0 3 13:57:15 server mountd[928]: Caught signal 15, un-registering =
and exiting.
May=A0 3 13:57:15 serverkernel: [82562.372930] nfsd: last server has ex=
ited, flushing export cache
May=A0 3 13:57:16 serverkernel: [82563.499249] svc: failed to register =
lockdv1 RPC service (errno 97).
May=A0 3 13:57:16 serverkernel: [82563.501211] NFSD: Using /var/lib/nfs=
/v4recovery as the NFSv4 state recovery directory
May=A0 3 13:57:16 serverkernel: [82563.501246] NFSD: starting 90-second=
 grace period

=A0
How can I fix that failure?


// Naderan *Mahmood;
