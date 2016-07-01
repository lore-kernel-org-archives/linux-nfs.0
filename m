Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:9363 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751036AbcGARcz convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 13:32:55 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u61HOtUU130448
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jul 2016 13:32:03 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23wag12x2g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Fri, 01 Jul 2016 13:32:03 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Fri, 1 Jul 2016 13:32:02 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 93950C90043
	for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2016 13:31:51 -0400 (EDT)
Received: from b01ledav002.gho.pok.ibm.com (b01ledav002.gho.pok.ibm.com [9.57.199.107])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u61HW3pk57016574
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jul 2016 17:32:03 GMT
Received: from b01ledav002.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9805D30003
	for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2016 13:32:00 -0400 (EDT)
Received: from d50lp02.ny.us.ibm.com (unknown [146.89.104.208])
	by b01ledav002.gho.pok.ibm.com (Postfix) with ESMTPS id 834F3124049
	for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2016 13:32:00 -0400 (EDT)
Received: from localhost
	by d50lp02.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Fri, 1 Jul 2016 13:32:00 -0400
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Fri, 1 Jul 2016 17:31:57 -0000
In-Reply-To: <20160701160857.GB20327@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: grace period
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Fri, 1 Jul 2016 10:31:55 -0700
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
 <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
 <20160701160857.GB20327@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It used to be that sending KILL signal to lockd would free locks and start 
Grace period, and when setting nfsd threads to zero, nfsd_last_thread() 
calls nfsd_shutdown that called lockd_down that I believe was causing both 
freeing of locks and starting grace period or maybe it was setting it back 
to a value > 0 that started the grace period.
Any way starting with the kernels that are in RHEL7.1 and up echo 0 > 
/proc/fs/nfsd/threads doesn't do it anymore, I assume going to common 
grace period for NLM and NFSv4 changed things.
The question is how to do IP fail-over, so when a node fails and the IP is 
moving to another node, we need to go into grace period on all the nodes 
in the cluster so the locks of the failed node are not given to anyone 
other than the client that is reclaiming his locks. Restarting NFS server 
is to distractive. For NFSv3 KILL signal to lockd still works but for 
NFSv4 have no way to do it for v4.
Marc. 



From:   Bruce Fields <bfields@fieldses.org>
To:     Marc Eshel/Almaden/IBM@IBMUS
Cc:     linux-nfs@vger.kernel.org
Date:   07/01/2016 09:09 AM
Subject:        Re: grace period



On Thu, Jun 30, 2016 at 02:46:19PM -0700, Marc Eshel wrote:
> I see that setting the number of nfsd threads to 0 (echo 0 > 
> /proc/fs/nfsd/threads) is not releasing the locks and putting the server 

> in grace mode.

Writing 0 to /proc/fs/nfsd/threads shuts down knfsd.  So it should
certainly drop locks.  If that's not happening, there's a bug, but we'd
need to know more details (version numbers, etc.) to help.

That alone has never been enough to start a grace period--you'd have to
start knfsd again to do that.

> What is the best way to go into grace period, in new version of the
> kernel, without restarting the nfs server?

Restarting the nfs server is the only way.  That's true on older kernels
true, as far as I know.  (OK, you can apparently make lockd do something
like this with a signal, I don't know if that's used much, and I doubt
it works outside an NFSv3-only environment.)

So if you want locks dropped and a new grace period, then you should run
"systemctl restart nfs-server", or your distro's equivalent.

But you're probably doing something more complicated than that.  I'm not
sure I understand the question....

--b.





