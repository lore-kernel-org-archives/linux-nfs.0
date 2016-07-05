Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:15421 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750984AbcGEXGH convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jul 2016 19:06:07 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65Mx31k072879
	for <linux-nfs@vger.kernel.org>; Tue, 5 Jul 2016 19:06:05 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 240ndn97ut-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 05 Jul 2016 19:06:05 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 5 Jul 2016 17:06:04 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5CCA81FF0046
	for <linux-nfs@vger.kernel.org>; Tue,  5 Jul 2016 17:05:45 -0600 (MDT)
Received: from b03ledav005.gho.boulder.ibm.com (b03ledav005.gho.boulder.ibm.com [9.17.130.236])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u65N61ZR51183870
	for <linux-nfs@vger.kernel.org>; Tue, 5 Jul 2016 16:06:01 -0700
Received: from b03ledav005.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DD622BE03A
	for <linux-nfs@vger.kernel.org>; Tue,  5 Jul 2016 17:06:01 -0600 (MDT)
Received: from d50lp01.ny.us.ibm.com (unknown [146.89.104.207])
	by b03ledav005.gho.boulder.ibm.com (Postfix) with ESMTPS id A09F9BE044
	for <linux-nfs@vger.kernel.org>; Tue,  5 Jul 2016 17:06:01 -0600 (MDT)
Received: from localhost
	by d50lp01.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 5 Jul 2016 19:06:00 -0400
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 5 Jul 2016 23:05:58 -0000
In-Reply-To: <20160705205130.GA12351@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
Subject: Re: grace period
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Tue, 5 Jul 2016 16:05:56 -0700
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
 <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
 <20160701160857.GB20327@fieldses.org>
 <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
 <20160701200742.GA24269@fieldses.org>
 <OF5D486F02.62CECB7B-ON88257FE3.0071DBE5-88257FE3.00722388@notes.na.collabserv.com>
 <20160701210151.GE24269@fieldses.org>
 <OF79A36FEE.749D5EF5-ON88257FE3.007C9721-88257FE3.007CC2B1@notes.na.collabserv.com>
 <20160702005820.GA27063@fieldses.org>
 <OFC1237E53.3CFCA8E8-ON88257FE5.001D3182-88257FE5.001E3AE3@notes.na.collabserv.com>
 <20160705205130.GA12351@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OF9CFDF514.E5B5F6CB-ON88257FE7.007EA497-88257FE7.007EE256@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Can you please point me to the kernel that you are using so I can check if 
it is an obvious problem before I open an RHEL bug?
Thanks, Marc. 



From:   Bruce Fields <bfields@fieldses.org>
To:     Marc Eshel/Almaden/IBM@IBMUS
Cc:     linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
Date:   07/05/2016 01:52 PM
Subject:        Re: grace period
Sent by:        linux-nfs-owner@vger.kernel.org



On Sat, Jul 02, 2016 at 10:30:11PM -0700, Marc Eshel wrote:
> I tried again NFSv3 locks with xfs export. "echo 0 > 
> /proc/fs/nfsd/threads" releases locks on rhel7.0 but not on rhel7.2
> What else can I show you to find the problem?

Sorry, I can't reproduce, though I've only tried a slightly later kernel
than that.  Could you submit a RHEL bug?

--b.

> Marc.
> 
> works:
> [root@boar11 ~]# uname -a
> Linux boar11 3.10.0-123.el7.x86_64 #1 SMP Mon May 5 11:16:57 EDT 2014 
> x86_64 x86_64 x86_64 GNU/Linux
> [root@boar11 ~]# cat /etc/redhat-release 
> Red Hat Enterprise Linux Server release 7.0 (Maipo)
> 
> not working:
> [root@sonascl21 ~]# uname -a
> Linux sonascl21.sonasad.almaden.ibm.com 3.10.0-327.el7.x86_64 #1 SMP Thu 

> Oct 29 17:29:29 EDT 2015 x86_64 x86_64 x86_64 GNU/Linux
> [root@sonascl21 ~]# cat /etc/redhat-release 
> Red Hat Enterprise Linux Server release 7.2 (Maipo)
> [root@sonascl21 ~]# cat /proc/fs/nfsd/threads 
> 0
> [root@sonascl21 ~]# cat /proc/locks
> 1: POSIX  ADVISORY  WRITE 2346 fd:00:1612092569 0 9999
> 
> 
> 
> From:   Bruce Fields <bfields@fieldses.org>
> To:     Marc Eshel/Almaden/IBM@IBMUS
> Cc:     linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
> Date:   07/01/2016 05:58 PM
> Subject:        Re: grace period
> 
> 
> 
> On Fri, Jul 01, 2016 at 03:42:43PM -0700, Marc Eshel wrote:
> > Yes, the locks are requested from another node, what fs are you using, 
I 
> 
> > don't think it should make any difference, but I can try it with the 
> same 
> > fs. 
> > Make sure you are using v3, it does work for v4.
> 
> I tested v3 on upstream.--b.
> 
> > Marc.
> > 
> > 
> > 
> > From:   Bruce Fields <bfields@fieldses.org>
> > To:     Marc Eshel/Almaden/IBM@IBMUS
> > Cc:     linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
> > Date:   07/01/2016 02:01 PM
> > Subject:        Re: grace period
> > 
> > 
> > 
> > On Fri, Jul 01, 2016 at 01:46:42PM -0700, Marc Eshel wrote:
> > > This is my v3 test that show the lock still there after echo 0 > 
> > > /proc/fs/nfsd/threads
> > > 
> > > [root@sonascl21 ~]# cat /etc/redhat-release 
> > > Red Hat Enterprise Linux Server release 7.2 (Maipo)
> > > 
> > > [root@sonascl21 ~]# uname -a
> > > Linux sonascl21.sonasad.almaden.ibm.com 3.10.0-327.el7.x86_64 #1 SMP 

> Thu 
> > 
> > > Oct 29 17:29:29 EDT 2015 x86_64 x86_64 x86_64 GNU/Linux
> > > 
> > > [root@sonascl21 ~]# cat /proc/locks | grep 999
> > > 3: POSIX  ADVISORY  WRITE 2349 00:2a:489486 0 999
> > > 
> > > [root@sonascl21 ~]# echo 0 > /proc/fs/nfsd/threads
> > > [root@sonascl21 ~]# cat /proc/fs/nfsd/threads
> > > 0
> > > 
> > > [root@sonascl21 ~]# cat /proc/locks | grep 999
> > > 3: POSIX  ADVISORY  WRITE 2349 00:2a:489486 0 999
> > 
> > Huh, that's not what I see.  Are you positive that's the lock on the
> > backend filesystem and not the client-side lock (in case you're doing 
a
> > loopback mount?)
> > 
> > --b.
> > 
> > > 
> > > 
> > > 
> > > 
> > > From:   Bruce Fields <bfields@fieldses.org>
> > > To:     Marc Eshel/Almaden/IBM@IBMUS
> > > Cc:     linux-nfs@vger.kernel.org
> > > Date:   07/01/2016 01:07 PM
> > > Subject:        Re: grace period
> > > 
> > > 
> > > 
> > > On Fri, Jul 01, 2016 at 10:31:55AM -0700, Marc Eshel wrote:
> > > > It used to be that sending KILL signal to lockd would free locks 
and 
> 
> > > start 
> > > > Grace period, and when setting nfsd threads to zero, 
> > nfsd_last_thread() 
> > > > calls nfsd_shutdown that called lockd_down that I believe was 
> causing 
> > > both 
> > > > freeing of locks and starting grace period or maybe it was setting 

> it 
> > > back 
> > > > to a value > 0 that started the grace period.
> > > 
> > > OK, apologies, I didn't know (or forgot) that.
> > > 
> > > > Any way starting with the kernels that are in RHEL7.1 and up echo 
0 
> > 
> > > > /proc/fs/nfsd/threads doesn't do it anymore, I assume going to 
> common 
> > > > grace period for NLM and NFSv4 changed things.
> > > > The question is how to do IP fail-over, so when a node fails and 
the 
> 
> > IP 
> > > is 
> > > > moving to another node, we need to go into grace period on all the 

> > nodes 
> > > 
> > > > in the cluster so the locks of the failed node are not given to 
> anyone 
> > 
> > > > other than the client that is reclaiming his locks. Restarting NFS 

> > > server 
> > > > is to distractive.
> > > 
> > > What's the difference?  Just that clients don't have to reestablish 
> tcp
> > > connections?
> > > 
> > > --b.
> > > 
> > > > For NFSv3 KILL signal to lockd still works but for 
> > > > NFSv4 have no way to do it for v4.
> > > > Marc. 
> > > > 
> > > > 
> > > > 
> > > > From:   Bruce Fields <bfields@fieldses.org>
> > > > To:     Marc Eshel/Almaden/IBM@IBMUS
> > > > Cc:     linux-nfs@vger.kernel.org
> > > > Date:   07/01/2016 09:09 AM
> > > > Subject:        Re: grace period
> > > > 
> > > > 
> > > > 
> > > > On Thu, Jun 30, 2016 at 02:46:19PM -0700, Marc Eshel wrote:
> > > > > I see that setting the number of nfsd threads to 0 (echo 0 > 
> > > > > /proc/fs/nfsd/threads) is not releasing the locks and putting 
the 
> > > server 
> > > > 
> > > > > in grace mode.
> > > > 
> > > > Writing 0 to /proc/fs/nfsd/threads shuts down knfsd.  So it should
> > > > certainly drop locks.  If that's not happening, there's a bug, but 

> > we'd
> > > > need to know more details (version numbers, etc.) to help.
> > > > 
> > > > That alone has never been enough to start a grace period--you'd 
have 
> 
> > to
> > > > start knfsd again to do that.
> > > > 
> > > > > What is the best way to go into grace period, in new version of 
> the
> > > > > kernel, without restarting the nfs server?
> > > > 
> > > > Restarting the nfs server is the only way.  That's true on older 
> > kernels
> > > > true, as far as I know.  (OK, you can apparently make lockd do 
> > something
> > > > like this with a signal, I don't know if that's used much, and I 
> doubt
> > > > it works outside an NFSv3-only environment.)
> > > > 
> > > > So if you want locks dropped and a new grace period, then you 
should 
> 
> > run
> > > > "systemctl restart nfs-server", or your distro's equivalent.
> > > > 
> > > > But you're probably doing something more complicated than that. 
I'm 
> 
> > not
> > > > sure I understand the question....
> > > > 
> > > > --b.
> > > > 
> > > > 
> > > > 
> > > > 
> > > 
> > > 
> > > 
> > > 
> > 
> > 
> > 
> > 
> 
> 
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html





