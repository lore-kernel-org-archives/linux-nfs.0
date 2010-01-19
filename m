From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Weird exportfs behavior
Date: Tue, 19 Jan 2010 15:32:10 -0500
Message-ID: <1263933130.2399.160.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.67.2]:41558 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871Ab0ASUgv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jan 2010 15:36:51 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,
	I'm working on a new export option for labeled nfs and I'm getting some
really weird behavior out of exportfs. I reverted my work to see if it
was the cause of the problem however the error still persists. For a
while I was getting errors about exportfs not knowing about
no_all_squashlabelloc=key so I tried to fix that and in the process I'd
had managed to get it to ignore labelloc all together. I don't think
that is the cause of the problems though. When I cat /var/lib/nfs/etab I
get a really weird line.

/exports	*(rw,sync,wdelay,security_label,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=0,anonuid=65534,anongid=65534,sec=unix,rw,root_squash,no_all_squash)

if you notice rw,root_squash, and no_all_squash are in that line twice.
I can't seem to figure out where the second set of those come from. I
believe that is causing the problem with my labelloc export because I
can't figure out how to get the last no_all_squash to have a comma after
it. It seems odd to me that this is doubled and I'm guessing it might be
a bug. I'm using the kernel and nfs-utils git hashes below.

Kernel: 22763c5cf3690a681551162c15d34d935308c8d7 (with LNFS patches)
nfs-utils: 1a1f991870f02b303a05e1d63915226e7cfb9f53 (with LNFS patches)

Dave

