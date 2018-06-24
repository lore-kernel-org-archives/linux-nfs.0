Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kalahimbra.net ([138.201.151.60]:58850 "EHLO
        mail.kalahimbra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751183AbeFXUkQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jun 2018 16:40:16 -0400
Received: from [192.168.178.46] (p5DC76577.dip0.t-ipconnect.de [93.199.101.119])
        by mail.kalahimbra.net (Postfix) with ESMTPSA id DE95E20242
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jun 2018 22:30:08 +0200 (CEST)
From: =?UTF-8?B?QXJtaW4gR3LDtsOfbGluZ2Vy?=
        <armin.groesslinger@uni-passau.de>
Subject: Commit which exposes blocked tasks with NFSv4.0 and Kerberos
To: linux-nfs@vger.kernel.org
Message-ID: <12dbf081-259b-edbc-bf4e-d9dc1b77fc9b@uni-passau.de>
Date: Sun, 24 Jun 2018 22:30:29 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello NFS developers,

I've written to this list before [1],[2] concerning uninterruptible hung
tasks in clients using NFSv4.0 with Kerberos. I have also written
scripts (which can be cloned from [3]) which help to reproduce the hangs
by configuring two virtual machines with the required setup and a test
program which triggers the hangs rather quickly (see [2] for details).

Meanwhile, I have been able to do some bisecting of kernel sources to
find a commit which exposes the hangs. It seems that since commit

2aca5b869ace67a63aab895659e5dc14c33a4d6e
SUNRPC: Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT

(introduced with v3.18-rc1) the uninterruptible hangs occur. When I
revert this commit, then I do not observe the uninterruptible hangs.
I've tested this on Ubuntu 16.04's 4.4 kernel and Debian 9's 4.9 kernel
and several stock kernels.

In our group at the university, we have about 15 desktop machines and 70
nodes in a SLURM cluster. Without reverting the commit, we've had on
average one machine per day locking up with uninterruptible hanging
tasks reported by the kernel; for about 6 weeks, we now run only kernels
with the commit reverted (i.e., Debian/Ubuntu's kernel recompiled after
reverting the patch) and we have not had any NFS-related machine lockups
so far.

I'm not claiming that the mentioned commit is the cause of the problem;
I think it exposes the problem. The problem is also present in current
kernels. Unfortunately, there seems to be another problem which can be
triggered by my test program from [3]. Since commit

9b30889c548a4d45bfe6226e58de32504c1d682f
SUNRPC: Ensure we always close the socket after a connection shuts down

(introduced with v4.16-rc1) is is very likely that the system dies due
to an out of memory condition, i.e., at some point the kernel consumes
all the memory and the OOM killer kills all user processes. When this
commit is reverted, I can observe the uninterruptible hung tasks again
(with kernel up to 4.18-rc2).

Since I have no expertise in the NFS client implementation, I'm still
hoping that exports on this list have an idea how to fix the NFS
client's behavior.

Regards,
Armin



[1] https://marc.info/?l=linux-nfs&m=150620442017672

[2] https://marc.info/?l=linux-nfs&m=152396752525579

[3] https://gitlab.infosun.fim.uni-passau.de/groessli/nfs-krb5-vms

