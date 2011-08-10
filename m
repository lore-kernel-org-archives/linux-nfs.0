Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:54795 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1HJAyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Aug 2011 20:54:46 -0400
Message-ID: <4E41D6AB.2080909@panasas.com>
Date: Tue, 9 Aug 2011 17:54:03 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Gregory Magoon <gmagoon@mit.edu>
CC: "Loewe, Bill" <bloewe@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@citi.umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu> <1311886684.27285.8.camel@lade.trondhjem.org> <20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu> <1311889677.27285.14.camel@lade.trondhjem.org> <20110728180120.bf6gq5zyos8wwg4s@webmail.mit.edu> <4E31E336.9090702@panasas.com> <20110728191519.ql5la3phk4000ko4@webmail.mit.edu> <4E337844.2070800@panasas.com> <717300C842BCD249A6A8CADE9995E130093FDE07@seabiscuit.int.panasas.com> <20110802121913.y5qpfnkftw00o00s@webmail.mit.edu> <20110809191500.2rm2rkclk408k0o0@webmail.mit.edu>
In-Reply-To: <20110809191500.2rm2rkclk408k0o0@webmail.mit.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/09/2011 04:15 PM, Gregory Magoon wrote:
> Just a quick follow-up...I was wondering if anyone had the chance to 
> take a look
> at the tcpdump I sent to a few of you last week.
> 
> If anyone else on the list wants to take a look, please let me know, 
> and I will
> send you the link privately.
> 

I will not have any bandwidth to look at the logs any time soon.

One thing that you should do is find out what is the exact test that is
failing. And is it really using the Linux-Kernel nfs client or if it is
using mpi's private nfs client.

Please find out the exact mpi command that is ran and all its command line
switches it uses.

Try to reproduce the problem not with "make test" but with the exact command
above that fails. Send me the command I'll have a look.

Boaz

> Thanks,
> Greg
> 
> Quoting Gregory Magoon <gmagoon@MIT.EDU>:
> 
>> Thanks all for the feedback and sorry for the delay...one of our HDDs 
>> failed on
>> Saturday, so I had to take care of that.
>>
>> Because I don't want to interrupt a working system, it will not be convenient
>> for me to try the "no delegations" option that has been suggested.
>>
>> I was however, able to grab a hold of a temporarily free node (temporarily
>> returned to NFSv4 configuration) to capture the tcp traffic. I have sent a
>> short (< 1 sec) snapshot captured during (I believe) the allred3 
>> mpich2 test. I
>> have privately sent you a link to the file. Hopefully the issue will 
>> be obvious
>> from this (e.g. you will immediately see that I am doing something I 
>> shouldn't
>> be doing). If a longer snapshot started before the tests would be 
>> useful, I can
>> get that too.
>>
>> I had posted on the mpich mailing list before I came here (
>> http://lists.mcs.anl.gov/pipermail/mpich-discuss/2011-July/010432.html ) and
>> unfortunately they weren't able to provide any insights.
>>
>> Thanks again,
>> Greg
>>
>>
>> Quoting "Loewe, Bill" <bloewe@panasas.com>:
>>
>>> Hi Greg,
>>>
>>> IOR is independent of MPICH2, but does require MPI for process 
>>> coordination.  By default, IOR will use the "-a POSIX" option for 
>>> standard POSIX I/O -- open(), write(), close(), etc.
>>>
>>> In addition, IOR can use the MPI-IO library calls (MPI_File_open(), 
>>> etc.) to perform I/O.
>>>
>>> For the build process of MPICH2 "make tests" exercises this MPI-IO 
>>> (ROMIO) interface which uses an ADIO (Abstract-Device Interface for 
>>> I/O) layer.  ADIO can interface to different file systems (NFS, 
>>> PanFS, PVFS2, Lustre, e.g.).
>>>
>>> The errors you're encountering in "make tests" for MPICH2 do not 
>>> appear to be testing the I/O, however, but seem to be an issue with 
>>> the launcher for the tests in general.  I agree with Boaz that it 
>>> may make sense to follow up with the MPICH developers for this.  
>>> Under their main page 
>>> (http://www.mcs.anl.gov/research/projects/mpich2/) they have a 
>>> support pulldown with FAQ and a mailing list.  They may be able to 
>>> help resolve this for you.
>>>
>>> Thanks,
>>>
>>> --Bill.
>>>
>>> -----Original Message-----
>>> From: Harrosh, Boaz
>>> Sent: Friday, July 29, 2011 8:20 PM
>>> To: Gregory Magoon
>>> Cc: Trond Myklebust; linux-nfs@vger.kernel.org; J. Bruce Fields; Loewe, Bill
>>> Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
>>>
>>> On 07/28/2011 04:15 PM, Gregory Magoon wrote:
>>>> Unfortunately, I'm not familiar enough with MPICH2 to have an idea about
>>>> significant changes between version 1.3 and 1.4, but other evidence 
>>>> suggests
>>>> that the version is not the issue and that I would have the same 
>>>> problem with
>>>> v1.3.
>>>>
>>>> I'm using the MPICH2 test suite invoked by "make testing" (see below
>>>> for initial
>>>> output).
>>>>
>>>> I'm using the nfs-kernel-server and nfs-common Ubuntu packages (natty
>>>> release).
>>>>
>>>
>>> You have not answered the most important question:
>>>>> Also are you using the builtin nfs-client driver or the POSIX interface?
>>>
>>> Which I'll assume means you don't know. So I'll try to elaborate. Just for
>>> background, I've never used "make tests" before all I used was IOR & mdtest.
>>>
>>> Now if you print the usage string for IOR you get this option:
>>>
>>> 	-a S  api --  API for I/O [POSIX|MPIIO|HDF5|NCMPI]
>>>
>>> I'm not familiar with the code but what I understand is only "-a 
>>> POSIX" will actually
>>> use the regular Kernel VFS interface for read/writing of files. The 
>>> other options
>>> have different drivers for different protocols. I do not know first 
>>> hand, but I once
>>> heard in a conference that -a MPIIO has a special NFS driver that 
>>> uses better NFS
>>> semantics and avoids the POSIX semantics which are bad for big 
>>> cluster performance.
>>> All this is speculations and rumors on my part, and you will need to 
>>> consult with the
>>> mpich guys.
>>>
>>> Now I can imagine that a "make tests" would try all possible 
>>> combinations of "-a S"
>>> So you'll need to dig out what is the falling test and is it really 
>>> using the Kernel
>>> NFS driver at that point. (I bet if you do a tcpdump like Bruce said 
>>> the guys here will
>>> be able to see if this is a Linux NFS or not)
>>>
>>> I CC: Bill Loewe that might know much more then me about this 
>>> subject. And please do
>>> speak with the MPICH people (But keep us in the loop it is 
>>> interesting to know)
>>>
>>> Thanks
>>> Boaz
>>>
>>>> Thanks,
>>>> Greg
>>>>
>>>> user@node01:~/Molpro/src/mpich2-1.4$ make testing
>>>> (cd test && make testing)
>>>> make[1]: Entering directory `/home/user/Molpro/src/mpich2-1.4/test'
>>>> (NOXMLCLOSE=YES && export NOXMLCLOSE && cd mpi && make testing)
>>>> make[2]: Entering directory `/home/user/Molpro/src/mpich2-1.4/test/mpi'
>>>> ./runtests -srcdir=. -tests=testlist \
>>>>                     
>>>> -mpiexec=/home/user/Molpro/src/mpich2-install/bin/mpiexec \
>>>>                     -xmlfile=summary.xml
>>>> Looking in ./testlist
>>>> Processing directory attr
>>>> Looking in ./attr/testlist
>>>> Processing directory coll
>>>> Looking in ./coll/testlist
>>>> Unexpected output in allred: [mpiexec@node01] APPLICATION TIMED OUT
>>>> Unexpected output in allred: [proxy:0:0@node01] 
>>>> HYD_pmcd_pmip_control_cmd_cb
>>>> (./pm/pmiserv/pmip_cb.c:906): assert (!closed) failed
>>>> Unexpected output in allred: [proxy:0:0@node01] 
>>>> HYDT_dmxu_poll_wait_for_event
>>>> (./tools/demux/demux_poll.c:77): callback returned error status
>>>> Unexpected output in allred: [proxy:0:0@node01] main
>>>> (./pm/pmiserv/pmip.c:226):
>>>> demux engine error waiting for event
>>>> Unexpected output in allred: [mpiexec@node01] HYDT_bscu_wait_for_completion
>>>> (./tools/bootstrap/utils/bscu_wait.c:70): one of the processes terminated
>>>> badly; aborting
>>>> Unexpected output in allred: [mpiexec@node01] HYDT_bsci_wait_for_completion
>>>> (./tools/bootstrap/src/bsci_wait.c:23): launcher returned error waiting for
>>>> completion
>>>> Unexpected output in allred: [mpiexec@node01] HYD_pmci_wait_for_completion
>>>> (./pm/pmiserv/pmiserv_pmci.c:189): launcher returned error waiting for
>>>> completion
>>>> Unexpected output in allred: [mpiexec@node01] main 
>>>> (./ui/mpich/mpiexec.c:397):
>>>> process manager error waiting for completion
>>>> Program allred exited without No Errors
>>>>
>>>>>
>>>>> Hi Gregory
>>>>>
>>>>> We are using MPICH2-1.3.1 and the IOR mpich test. as well as the mdtest
>>>>> test. And have had no issues so far with nfsv4 nfsv4.1 and pnfs. In fact
>>>>> this is our standard performance test.
>>>>>
>>>>> What tests are you using?
>>>>> Do you know of any major changes between MPICH2-1.3.1 and MPICH2-1.4?
>>>>> Also are you using the builtin nfs-client driver or the POSIX interface?
>>>>>
>>>>> Boaz
>>>>>
>>>>
>>>>
>>>
>>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 

