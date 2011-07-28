Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-4.MIT.EDU ([18.9.25.15]:51895 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754031Ab1G1XPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 19:15:38 -0400
Message-ID: <20110728191519.ql5la3phk4000ko4@webmail.mit.edu>
Date: Thu, 28 Jul 2011 19:15:19 -0400
From: Gregory Magoon <gmagoon@MIT.EDU>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
	<1311886684.27285.8.camel@lade.trondhjem.org>
	<20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu>
	<1311889677.27285.14.camel@lade.trondhjem.org>
	<20110728180120.bf6gq5zyos8wwg4s@webmail.mit.edu>
	<4E31E336.9090702@panasas.com>
In-Reply-To: <4E31E336.9090702@panasas.com>
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Unfortunately, I'm not familiar enough with MPICH2 to have an idea about
significant changes between version 1.3 and 1.4, but other evidence suggests
that the version is not the issue and that I would have the same problem with
v1.3.

I'm using the MPICH2 test suite invoked by "make testing" (see below 
for initial
output).

I'm using the nfs-kernel-server and nfs-common Ubuntu packages (natty 
release).

Thanks,
Greg

user@node01:~/Molpro/src/mpich2-1.4$ make testing
(cd test && make testing)
make[1]: Entering directory `/home/user/Molpro/src/mpich2-1.4/test'
(NOXMLCLOSE=YES && export NOXMLCLOSE && cd mpi && make testing)
make[2]: Entering directory `/home/user/Molpro/src/mpich2-1.4/test/mpi'
./runtests -srcdir=. -tests=testlist \
                    -mpiexec=/home/user/Molpro/src/mpich2-install/bin/mpiexec \
                    -xmlfile=summary.xml
Looking in ./testlist
Processing directory attr
Looking in ./attr/testlist
Processing directory coll
Looking in ./coll/testlist
Unexpected output in allred: [mpiexec@node01] APPLICATION TIMED OUT
Unexpected output in allred: [proxy:0:0@node01] HYD_pmcd_pmip_control_cmd_cb
(./pm/pmiserv/pmip_cb.c:906): assert (!closed) failed
Unexpected output in allred: [proxy:0:0@node01] HYDT_dmxu_poll_wait_for_event
(./tools/demux/demux_poll.c:77): callback returned error status
Unexpected output in allred: [proxy:0:0@node01] main 
(./pm/pmiserv/pmip.c:226):
demux engine error waiting for event
Unexpected output in allred: [mpiexec@node01] HYDT_bscu_wait_for_completion
(./tools/bootstrap/utils/bscu_wait.c:70): one of the processes terminated
badly; aborting
Unexpected output in allred: [mpiexec@node01] HYDT_bsci_wait_for_completion
(./tools/bootstrap/src/bsci_wait.c:23): launcher returned error waiting for
completion
Unexpected output in allred: [mpiexec@node01] HYD_pmci_wait_for_completion
(./pm/pmiserv/pmiserv_pmci.c:189): launcher returned error waiting for
completion
Unexpected output in allred: [mpiexec@node01] main (./ui/mpich/mpiexec.c:397):
process manager error waiting for completion
Program allred exited without No Errors

>
> Hi Gregory
>
> We are using MPICH2-1.3.1 and the IOR mpich test. as well as the mdtest
> test. And have had no issues so far with nfsv4 nfsv4.1 and pnfs. In fact
> this is our standard performance test.
>
> What tests are you using?
> Do you know of any major changes between MPICH2-1.3.1 and MPICH2-1.4?
> Also are you using the builtin nfs-client driver or the POSIX interface?
>
> Boaz
>


