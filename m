Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65416.mail.ac4.yahoo.com ([76.13.9.36]:39813 "HELO
	web65416.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751673Ab1DKNbh convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2011 09:31:37 -0400
Message-ID: <248855.78516.qm@web65416.mail.ac4.yahoo.com>
Date: Mon, 11 Apr 2011 06:31:34 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
In-Reply-To: <F8F557F7-8799-449A-94FD-12FF5FC2974C@oracle.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--- On Fri, 4/8/11, Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 7, 2011, at 5:49 PM, Andrew Klaassen wrote:
> 
> > I just got myself edjumicated on smp_affinity, and now
> > I'm able to achieve 99% CPU usage by 8 nfsd processes on 8
> > cores on a read-only, fully-cached workload, with ksoftirqd
> > processes only using 1% CPU per core.
> > 
> > Unfortunately, this doesn't help the "ls -l" speed.
> 
> Serving NFS files is generally not CPU intensive.  The
> problem may be lock contention on the server, but that's
> about as far as my expertise goes.

In that case the test workload was fully cached in memory, so I'm not completely surprised.

Andrew


