Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:11990 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751900AbcGAUZB convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 16:25:01 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u61KOsXT108678
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jul 2016 16:25:00 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23wbt3vwkc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Fri, 01 Jul 2016 16:25:00 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Fri, 1 Jul 2016 14:25:00 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C7AD119D8026
	for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2016 14:24:33 -0600 (MDT)
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u61KOspd43843766
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jul 2016 13:24:56 -0700
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F0EE56E04C
	for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2016 14:24:55 -0600 (MDT)
Received: from d50lp03.ny.us.ibm.com (unknown [146.89.104.211])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTPS id B50BF6E044
	for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2016 14:24:55 -0600 (MDT)
Received: from localhost
	by d50lp03.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Fri, 1 Jul 2016 16:24:55 -0400
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Fri, 1 Jul 2016 20:24:51 -0000
In-Reply-To: <20160701200742.GA24269@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, "Tomer Perry" <TOMP@il.ibm.com>
Subject: Re: grace period
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Fri, 1 Jul 2016 13:24:48 -0700
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
 <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
 <20160701160857.GB20327@fieldses.org>
 <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
 <20160701200742.GA24269@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OF92EFA45C.4AE993A0-ON88257FE3.006F2AAB-88257FE3.00702245@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux-nfs-owner@vger.kernel.org wrote on 07/01/2016 01:07:42 PM:

> From: Bruce Fields <bfields@fieldses.org>
> To: Marc Eshel/Almaden/IBM@IBMUS
> Cc: linux-nfs@vger.kernel.org
> Date: 07/01/2016 01:07 PM
> Subject: Re: grace period
> Sent by: linux-nfs-owner@vger.kernel.org
> 
> On Fri, Jul 01, 2016 at 10:31:55AM -0700, Marc Eshel wrote:
> > It used to be that sending KILL signal to lockd would free locks and 
start 
> > Grace period, and when setting nfsd threads to zero, 
nfsd_last_thread() 
> > calls nfsd_shutdown that called lockd_down that I believe was causing 
both 
> > freeing of locks and starting grace period or maybe it was setting it 
back 
> > to a value > 0 that started the grace period.
> 
> OK, apologies, I didn't know (or forgot) that.
> 
> > Any way starting with the kernels that are in RHEL7.1 and up echo 0 > 
> > /proc/fs/nfsd/threads doesn't do it anymore, I assume going to common 
> > grace period for NLM and NFSv4 changed things.
> > The question is how to do IP fail-over, so when a node fails and the 
IP is 
> > moving to another node, we need to go into grace period on all the 
nodes 
> > in the cluster so the locks of the failed node are not given to anyone 

> > other than the client that is reclaiming his locks. Restarting NFS 
server 
> > is to distractive.
> 
> What's the difference?  Just that clients don't have to reestablish tcp
> connections?

I am not sure what else systemctl will do but I need to control the order 
of the restart so the client will not see any errors.
I don't think that echo 0 > /proc/fs/nfsd/threads is freeing the lock, at 
least not the v3 locks, I will try again with v4.
The question is what is the most basic operation that can be done to start 
grace, will echo 8 > /proc/fs/nfsd/threads following echo 0 do it?
or is there any other primitive that will do it?
Marc.

> 
> --b.
> 
> > For NFSv3 KILL signal to lockd still works but for 
> > NFSv4 have no way to do it for v4.
> > Marc. 
> > 
> > 
> > 
> > From:   Bruce Fields <bfields@fieldses.org>
> > To:     Marc Eshel/Almaden/IBM@IBMUS
> > Cc:     linux-nfs@vger.kernel.org
> > Date:   07/01/2016 09:09 AM
> > Subject:        Re: grace period
> > 
> > 
> > 
> > On Thu, Jun 30, 2016 at 02:46:19PM -0700, Marc Eshel wrote:
> > > I see that setting the number of nfsd threads to 0 (echo 0 > 
> > > /proc/fs/nfsd/threads) is not releasing the locks and putting the 
server 
> > 
> > > in grace mode.
> > 
> > Writing 0 to /proc/fs/nfsd/threads shuts down knfsd.  So it should
> > certainly drop locks.  If that's not happening, there's a bug, but 
we'd
> > need to know more details (version numbers, etc.) to help.
> > 
> > That alone has never been enough to start a grace period--you'd have 
to
> > start knfsd again to do that.
> > 
> > > What is the best way to go into grace period, in new version of the
> > > kernel, without restarting the nfs server?
> > 
> > Restarting the nfs server is the only way.  That's true on older 
kernels
> > true, as far as I know.  (OK, you can apparently make lockd do 
something
> > like this with a signal, I don't know if that's used much, and I doubt
> > it works outside an NFSv3-only environment.)
> > 
> > So if you want locks dropped and a new grace period, then you should 
run
> > "systemctl restart nfs-server", or your distro's equivalent.
> > 
> > But you're probably doing something more complicated than that.  I'm 
not
> > sure I understand the question....
> > 
> > --b.
> > 
> > 
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


