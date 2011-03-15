Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from milhouse.imppc.org ([213.151.98.37]:34939 "EHLO
	milhouse.imppc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab1COQZs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 12:25:48 -0400
Message-ID: <4D7F930A.1010509@imppc.org>
Date: Tue, 15 Mar 2011 17:25:46 +0100
From: Judith Flo Gaya <jflo@imppc.org>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: problem with nfs latency during high IO
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[Sorry if the e-mail appears to be duplicated, I don't see it in the 
list, but I sent it 3 days ago ;(]

Hello,

I was told some days ago that my problem with my NFS system is related 
to this bug, as the problem that I'm experiencing is quite similar.

The bug : https://bugzilla.redhat.com/show_bug.cgi?id=469848

The link itself explains quite well my issue, I'm just truing to copy a 
big file (36Gb) to my nfs server and when I try to get an ls -l command 
to the same folder where I'm copying data, the command gets stuck for 
some time. This amount of time changes from a few secs to SOME minutes 
(9' is the current record).
I can live with some seconds of delay, but minutes is something quite 
unacceptable.

As this is an nfs server running on a red hat system (an HP ibrix x9300 
with Red Hat 5.3 x86_64, kernel 2.6.18-128) I was told to apply the 
patch suggested from the bug on my clients.

Unfortunately my clients are running fedora core 14 (x86_64, kernel 
2.6.35.6-45) and I can't find the file that they are referring to, the 
file fs/nfs/inode.c is not there and I can't find the rpm that contains it.

As the bug is a very very old one, I took it for granted that is already 
applied to fedora, but I wanted to make sure that it is looking at the file.

Can you help me on this? I'm I wrong in my supposition (is the patch 
really applied)? is it possible that my problem is somewhere else?

Thanks a lot in advance for your help, please let me know if I can 
provide any more information.
j


