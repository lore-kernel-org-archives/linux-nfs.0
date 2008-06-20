From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Fri, 20 Jun 2008 12:09:11 +0530
Message-ID: <OF5312A09D.CAC110C0-ON6525746E.00245BF4-6525746E.00248C25@in.ibm.com>
References: <485A569A.8060601@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:33277 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751236AbYFTGkm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2008 02:40:42 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5K6eFTk012835
	for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2008 12:10:15 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5K6dKr5884874
	for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2008 12:09:20 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5K6eEOR009017
	for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2008 12:10:14 +0530
In-Reply-To: <485A569A.8060601@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Peter for your explanation, and Benny for this option I was not
aware of. Let me
run some tests with this option.

Regards,

- KK

linux-nfs-owner@vger.kernel.org wrote on 06/19/2008 06:22:42 PM:

> On Jun. 19, 2008, 15:04 +0300, Peter Staubach <staubach@redhat.com>
wrote:
> > Krishna Kumar2 wrote:
> >>>       200 processes:
> >>>
> >> By "200 processes", I meant 200 dd's, each reading from /dev/zero and
> >> writing to a file on the filesystem. The script "nfs" was run twice,
first
> >> with
> >> a local filesystem and the second time with the same filesystem NFS
> >> mounted.
> >>
> >>
> >
> > Well, you aren't exactly comparing apples to apples.  The NFS
> > client does close-to-open semantics, meaning that it writes
> > all modified data to the server on close.  The dd commands run
> > on the local file system do not.  You might trying using
> > something which does an fsync before closing so that you are
> > making a closer comparison.
>
> try dd conv=fsync ...
>
> Benny
>
> >
> > All that said, yes, one would expect a slow down.  How much is
> > debatable and varies from platform to platform and load to load.
> >
> > I would also advise care when running NFS like that.  It is
> > subject to deadlock and is not recommended.
> >
> >        ps
> >
> >> Thanks,
> >>
> >> - KK
> >>
> >> linux-nfs-owner@vger.kernel.org wrote on 06/19/2008 12:16:23 PM:
> >>
> >>
> >>> Hi,
> >>>
> >>> I am running 2.6.25 kernel on a [4 way, 3.2 x86_64, 4GB] system. The
test
> >>> is doing I/O on a local ext3 filesystem, and measuring the bandwidth,
and
> >>> then NFS mounting the filesystem loopback on the same system. I have
> >>> configured 64 nfsd's to run. The test script is attached at the
bottom.
> >>>
> >>> My configuration is:
> >>>       /dev/some-local-disk  :            /local
> >>>       NFS mount /local       :            /nfs
> >>>
> >>> The result is:
> >>>       200 processes:
> >>>             /local: 108000 KB/s
> >>>             /nfs:     66000 KB/s: Drop of 40%
> >>>
> >>>       300 processes (KB/s):
> >>>             /local: 112000 KB/s
> >>>             /nfs:    57000 KB/s: Drop of 50%
> >>>
> >>> I am not using any tuning, though I have tested with both
> >>> sunrpc.tcp_slot_table_entries=16 & 128
> >>>
> >>> Is this big a drop expected for a loopback NFS mount? Any
> >>> feedback/suggestions are very
> >>> appreciated.
> >>>
> >>> Thanks,
> >>>
> >>> - KK
> >>>
> >>> (See attached file: nfs)[attachment "nfs" deleted by Krishna
> >>>
> >> Kumar2/India/IBM]
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> --
> Benny Halevy
> Software Architect
> Tel/Fax: +972-3-647-8340
> Mobile: +972-54-802-8340
> bhalevy@panasas.com
>
> Panasas, Inc.
> The Leader in Parallel Storage
> www.panasas.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

