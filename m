Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:34506 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030763Ab2CFPJg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 10:09:36 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 6 Mar 2012 10:09:34 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 9E17838C807D
	for <linux-nfs@vger.kernel.org>; Tue,  6 Mar 2012 10:09:02 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q26F8veC268746
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 10:08:58 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q26F8laH012216
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 08:08:47 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q26F8hop011336
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 08:08:43 -0700
Date: Tue, 6 Mar 2012 09:08:43 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4: truncate returns I/O error
Message-ID: <20120306150842.GA7453@us.ibm.com>
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
 <1331043405.3260.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1331043405.3260.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> On Tue, 2012-03-06 at 11:10 +0100, Miklos Szeredi wrote:
> > The attached test program reliably fails on an NFSv4 mount.
> > 
> > # mount -tnfs -onfsvers=4 127.0.0.1:/ /mnt/nfs
> > # ./truncate-test /mnt/nfs/tmp/xyz
> > truncate: Input/output error
> > 
> > Thanks,
> > Miklos
> 
> Thanks! I'll see if I can reproduce and figure out what's going wrong.

I could reproduce on RHEL6.2. If I remove the second open (O_RDONLY),
then it works fine.

If I do "chmod" (probably others too) on that failing file, then truncate
works on it. Looks like some kind of attribute validation issue, I will
test it more if I get a chance.

Regards, Malahal.

