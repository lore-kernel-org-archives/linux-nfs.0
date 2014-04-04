Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:61495 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbaDDSPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2014 14:15:50 -0400
Date: Fri, 4 Apr 2014 13:15:33 -0500 (CDT)
From: Andrew Martin <amartin@xes-inc.com>
To: bhawley@luminex.com
Cc: Ric Wheeler <rwheeler@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jim Rees <rees@umich.edu>, Brown Neil <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Message-ID: <1705719437.438761.1396635333924.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <745339487-1394134695-cardhu_decombobulator_blackberry.rim.net-1127415581-@b5.c4.bise6.blackberry>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <1028951407-1394132418-cardhu_decombobulator_blackberry.rim.net-599891631-@b5.c4.bise6.blackberry> <E22EB8B3-DE5E-4D39-8FFD-BA3F02276EFE@primarydata.com> <745494581-1394133289-cardhu_decombobulator_blackberry.rim.net-1805734207-@b5.c4.bise6.blackberry> <5318CC8C.1050505@redhat.com> <745339487-1394134695-cardhu_decombobulator_blackberry.rim.net-1127415581-@b5.c4.bise6.blackberry>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

----- Original Message -----
> From: "Brian Hawley" <bhawley@luminex.com>
> To: "Ric Wheeler" <rwheeler@redhat.com>, "Brian Hawley" <bhawley@luminex.com>, "Trond Myklebust"
> <trond.myklebust@primarydata.com>
> Cc: "Andrew Martin" <amartin@xes-inc.com>, "Jim Rees" <rees@umich.edu>, "Brown Neil" <neilb@suse.de>,
> linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
> Sent: Thursday, March 6, 2014 1:38:15 PM
> Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
> 
> 
> I agree completely that the write() returning only means it's in the page
> cache.
> 
> I agree completely that fsync() result is the only way to know your data is
> safe.
> 
> Neither of those is what I, or the original poster (and what other posters in
> the past) on this subject are disputing or concerned about.
> 
> The issue is, the write() call (in my case - read() in the original posters
> case) does NOT return.
Is it possible with the "sync" mount option (or via another method) to force
all writes to fsync and fail immediately if they do not succeed? In other
words skip the cache? In some applications I'd rather pass the error back up 
to the application right away for it to handle (even if the error is caused 
by network turbulence) rather than risk getting into this situation where 
writes block forever.

Thanks,

Andrew
