Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay1.lrz-muenchen.de ([129.187.254.106]:46735 "EHLO
	mailrelay1.lrz-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750951Ab0FPIUm convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jun 2010 04:20:42 -0400
Received: from BALZ00SW-HBT2.ads.mwn.de (BALZ00SW-HBT2.ads.mwn.de [10.156.54.26]) by mailout.lrz-muenchen.de with ESMTP for linux-nfs@vger.kernel.org; Wed, 16 Jun 2010 10:20:17 +0200
From: Joschi Brauchle <joschi.brauchle@tum.de>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 16 Jun 2010 10:20:15 +0200
Subject: Syslog flooded: "NFSD: preprocess_seqid_op: magic stateid!"
Message-Id: <501A322854D4C944BCAF0528CFC7B65E3B30E7F5EE@BALZ00SW-MBX.ads.mwn.de>
Content-Type: text/plain; charset="Windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi everyone!
I’m brand-new on the list and I hope this is the right place to post my questions.
Please bear with me if there is some information missing,…

I am facing the following (first) problem on our primary NFSv4 fileserver (called pollux) running SLES 10SP3 
(Linux pollux 2.6.16.60-0.62.1-smp #1 SMP Mon Apr 12 18:53:46 UTC 2010 x86_64 x86_64 x86_64 GNU/Linux), 
the syslog is flooded with the following message:

Jun  3 15:29:24 pollux kernel: NFSD: preprocess_seqid_op: magic stateid!

I have increased the loglevel of the nfs daemon and get the following line right before the line above:

Jun  3 15:29:24 pollux kernel: NFSD: preprocess_seqid_op: seqid=208 stateid = (00000000/00000000/00000000/00000000)

We are running NFSv4 with Kerberos security, nfs-utils is the 1.0.7 Novell package for SLES10. 
I have to mention that everything is operating as it should. It is just annoying that our syslog receives about 13000 "magic stateid" lines a day.

Our "/etc/exports" looks like this:
# NFSv4 entries (with Kerberos and GSS Security):
/export                 gss/krb5(rw,fsid=0,no_all_squash,async,no_subtree_check)
# NFSv3 entries:
/export/opt             *(rw,no_all_squash,async,no_subtree_check)

I have tried to find anything helpful on google. The only things I found are indications that it might be related to the "nfsnobody" userid. Actually, we have a couple of nfs-client-machines (no user logged in) which access the /export nfsv4 share from a root-cronjob using their "nfs/f.q.d.n.@realm" Kerberos service creds, which are mapped then to the "nobody" user on the server. I have the feeling that the "magic stateid" lines started appearing since we installed those cronjobs on the clients.

Does anyone have some knowledge about this "magic stateid" message?
Any suggestions in debugging this issue?
Unfortunately, Novell support was not able to help us on this issue so far, thus I’m trying here ?

Second problem:
We recently downgraded from a patched nfs-utils 1.0.9 (patched to accept the “-h” option for different hostname in Kerberos service creds in a high availability environment) to the original Novell RPM providing nfs-utils 1.0.7 (now using the undocumented “-c” switch to read the accepted creds from keytab file). (Note: the first problem has already occurred before this downgrade)

Since this change, we are experiencing massive lags (1-10 sec freezes, irregularly, but a couple times an hour) on our client machines, which are mounting their homes via NFSv4. There seem to be no related messages or warnings on the server nor the clients.

We come to the conclusion that 1.0.9 was the more stable version. The resulting question is: Which nfs-utils version would be best suited for SLES10SP3 (see kernel version above). Can we go straight to the latest 1.2.2 available or should we stick with 1.0.xx version?

Thanks so much for you time!

Institute for Communications Engineering (LNT)
Technische Universitaet Muenchen (TUM)
80290 Munich, Germany

Tel (work): +49 89 289-23474
Fax (work): +49 89 289-23490
E-mail: joschi.brauchle@tum.de
Web: http://www.lnt.ei.tum.de/

