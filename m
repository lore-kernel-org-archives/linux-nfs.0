Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:37102 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbZBPI35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Feb 2009 03:29:57 -0500
Message-ID: <49991BE7.1090104@aei.mpg.de>
Date: Mon, 16 Feb 2009 08:55:19 +0100
From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        beowulf@beowulf.org
Subject: Tracing down 250ms open/chdir calls
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

sorry in advance for this vague subject and also the vague email, I'm
trying my best to summarize the problem:

On our large cluster we sometimes encounter the problem that our main
scheduling processes are often in state D and in the end not capable
anymore of pushing work to the cluster.

The head nodes are 8 core boxes with Xeon CPUs and equipped with 16 GB
of memory, when certain types of jobs are running we see system loads of
about 20-30 which might go up to 80-100 from time to time. Looking at
the individual cores they are mostly busy with system tasks (e.g. htop
shows 'red' bars).

stat -tt -c showed that several system calls of the scheduler take a
long time to complete, most notably open and chdir which took between
180 and 230ms to complete (during our testing). Since most of these open
and chdir are via NFSv3 I'm including that list as well. The NFS servers
are Sun Fire X4500 boxes running Solaris 10u5 right now.

A standard output line looks like:
93.37   38.997264     230753      169    78      open

i.e. 93.37% of the system-related time was spend in 169 successful open
calls which took 230753us/call, thus 39 wall clock seconds were spend in
a minute just doing open.

We tried several things to understand the problem, but apart from moving
more files (mostly log files of currently running jobs) off NFS we did
not move far ahead so far. On
https://n0.aei.uni-hannover.de/twiki/bin/view/ATLAS/H2Problems
we have summarized some things.

With the help of 'stress' and a tiny program just doing open/putc/close
into a single file, I've tried to get a feeling how good or bad things
are when compared to other head nodes with different tasks/loads:

https://n0.aei.uni-hannover.de/twiki/bin/view/ATLAS/OpenCloseIotest

(this test may or may not help in the long run, I'm just poking into the
dark).

Now my questions:

* Do you have any suggestions how to continue debugging this problem?
* Does anyone know how to improve the situation? Next on my agenda would
be to try different IO algorithms, any hints which ones should be good
for such boxes?
* I guess I missed vital information. please let me know if you need
more information of the system

Please Cc me from linux-kernel, I'm only on the other two addressed lists.

Cheers and a lot of TIA

Carsten

-- 
Dr. Carsten Aulbert - Max Planck Institute for Gravitational Physics
Callinstrasse 38, 30167 Hannover, Germany
Phone/Fax: +49 511 762-17185 / -17193
http://www.top500.org/system/9234 | http://www.top500.org/connfam/6/list/31
