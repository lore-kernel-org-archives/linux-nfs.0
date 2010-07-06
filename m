Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from iramx2.ira.uni-karlsruhe.de ([141.3.10.81]:53257 "EHLO
	iramx2.ira.uni-karlsruhe.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755392Ab0GFNEm convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 09:04:42 -0400
Received: from mail-bw0-f46.google.com ([209.85.214.46])
	by iramx2.ira.uni-karlsruhe.de with esmtpsa port 465
	id 1OW7Wc-0000s5-1G
	for <linux-nfs@vger.kernel.org>; Tue, 06 Jul 2010 14:45:29 +0200
Received: by bwz1 with SMTP id 1so3478003bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jul 2010 05:45:21 -0700 (PDT)
From: Mika Fischer <mika.fischer@kit.edu>
Date: Tue, 6 Jul 2010 14:45:01 +0200
Message-ID: <AANLkTim3hkqS-MivxL4C7Q7-xC_8P0ASPuKq-PKsZx5C@mail.gmail.com>
Subject: Bug: Cleaning up of kerberos credentials by SSH with kerberized NFS
	leads to excessive log spam by rpc.gssd
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

we're having the following problem at our institute where we use
Kerberos to secure our NFS mounts.

This is copied from the OpenSuSE bug report here:
https://bugzilla.novell.com/show_bug.cgi?id=620066

----
SSH by default deletes Kerberos credentials when a user logs out.

If the user left a program running (for instance via screen), and if Kerberos
credentials are needed to access the home directories (kerberized NFS),
rpc.gssd will fail to obtain Kerberos credentials.

The problem is that it generates excessive amounts of warnings in the syslog to
this effect (about 1100 warnings per second), which then quickly fill up the
hard drive.

Reproducible: Always

Steps to Reproduce:
1. Log in (via SSH) to host that mounts home directory via kerberized NFS
2. Start screen with some process accessing the home dir inside
3. Detach screen
4. Close SSH session
5. Wait for rpc.gssd credentials cache to expire
Actual Results:
When the process still running on the target host tries to access the home
directory, rpc.gssd will try and fail to obtain kerberos credentials for the
user. It will then spam the syslog with the following warning
----
<date> <hostname> rpc.gssd[<pid>]: WARNING: Failed to create krb5 context for
user with uid <uid> for server <other hostname>
----
This is repeated ad infinitum until the offending process is killed manually.
The logfile otherwise quickly fills up the partition.

Expected Results:
Maybe one warning or no warning at all should be emitted (the latter is the
case for *expired* credentials). See also
https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/293705 for the case of
expired credentials.
----

So it seems that for the case of expired credentials, this problem has
been addressed already. Now we're having the same problem with missing
credentials. Are we doing something wrong? I'm surprised that not more
people have run into this problem.

Any advice would be much appreciated.

Best,
 Mika
-- 
Mika Fischer                     email:  mika.fischer@kit.edu
Institut für Anthropomatik      phone:  +49 721 608 4735
Universität Karlsruhe (TH)      fax:    +49 721 60 77 21
Adenauerring 2                   web:    http://cvhci.ira.uka.de/~mfischer
76131 Karlsruhe                  office: room 228, building 50.20
