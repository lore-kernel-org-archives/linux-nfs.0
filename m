From: "K.Prasad" <prasad@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 15:43:29 +0530
Message-ID: <20090121101329.GA4876@in.ibm.com>
References: <49711BDF.3010605@melbourne.sgi.com> <x49ab9ntlpp.fsf@segfault.boston.devel.redhat.com>
Reply-To: prasad@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>,
	Christoph Hellwig <hch@infradead.org>,
	Maneesh Soni <maneesh@in.ibm.com>
To: Jeff Moyer <jmoyer@redhat.com>, Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from E23SMTP04.au.ibm.com ([202.81.18.173]:55393 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764274AbZAUKNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 05:13:44 -0500
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n0LAC0Cd018745
	for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2009 21:12:01 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0LADxOH4452412
	for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2009 21:13:59 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0LADehn025659
	for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2009 21:13:41 +1100
In-Reply-To: <x49ab9ntlpp.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 19, 2009 at 09:27:30AM -0500, Jeff Moyer wrote:
> Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> writes:
> 
> > Steve Dickson wrote:
> >> So the ultimate goal would be to replace all the dprintks with trace points
> >> but still be able to enable them through the rpcdebug command
> > I have a patch which changes the definition of the dprintk() macro (but
> > *not* dprintk() callsites) to allow enabling and disabling individual
> > dprintk() statements through a /proc/ interface.  Would you be
> > interested in that?
> 
> That sounds like duplicated work.  How does it differ from Jason Baron's
> dynamic printk patches (which I believe are now upstream)?
> 
> Cheers,
> Jeff

Introducing/converting one of the accepted methods of static
instrumentation - like tracepoints would help more users (whether
in-kernel or otherwise) harness them.

Steve,
	Would it help convert the systemtap script (nfs_mount.stp) in
Patch - 5 into a kernel module (perhaps in samples/ directory) to bring
an in-kernel user of these tracepoints?

Thanks,
K.Prasad

