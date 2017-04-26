Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23956 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbdDZReb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 13:34:31 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: NFSIOSTAT question
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AFC8A2987FAF1648BC4C4262CBC1B9DD47C20929@SXEMBP01.corp.dtcc.com>
Date: Wed, 26 Apr 2017 10:35:55 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <18DB2DBB-8658-44C2-AA82-E989B3928DAA@oracle.com>
References: <AFC8A2987FAF1648BC4C4262CBC1B9DD47C20929@SXEMBP01.corp.dtcc.com>
To: "Merritt, Steven" <smerritt@dtcc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2017, at 10:24 AM, Merritt, Steven <smerritt@dtcc.com> wrote:
> 
> Hey Chuck,
>  
> Love the NFSIOSTAT script.  Quick question if you have a second.  Trying to determine what is being measured by the  -d options.  We’re seeing output like this,
>  
> NetAppApplianceFQDN:/NetAppExport1 mounted on /mount/point/1:
>  
>    op/s         rpc bklog
> 26102.56           0.00
> lookup:           ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.000           0.000           0.270        0 (0.0%)           6.000           6.333
> readdir:          ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.000           0.000           0.000        0 (0.0%)           0.000           0.000
> readdirplus:      ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.000           0.000           0.000        0 (0.0%)           0.000           0.000
>  
> 0 open operations (pathname lookups)
> 0 dentry revalidates and 3 vfs lookup requests resulted in 3 LOOKUPs on the wire
> 0 vfs getdents calls resulted in 0 READDIRs on the wire
>  
> NetAppApplianceFQDN:/NetAppExport2 mounted on /mount/point/2:
>  
>    op/s         rpc bklog
> 26102.56           0.00
> lookup:           ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.617           0.283           0.458        0 (0.0%)           6.037           6.263
> readdir:          ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.014           0.059           4.131        0 (0.0%)           3.941           4.271
> readdirplus:      ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.000           0.000           0.703        0 (0.0%)           3.973           4.027
>  
> 2082 open operations (pathname lookups)
> 134807 dentry revalidates and 133443 vfs lookup requests resulted in 183282 LOOKUPs on the wire
> 632 vfs getdents calls resulted in 4254 READDIRs on the wire
>  
> NetAppApplianceFQDN: /NetAppExport3 mounted on /mount/point/3:
>  
>    op/s         rpc bklog
> 1586.50            0.00
> lookup:           ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                 225.500         103.941           0.461        0 (0.0%)           0.399           3.896
> readdir:          ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.000           0.000           0.000        0 (0.0%)           0.000           0.000
> readdirplus:      ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                   0.000           0.000           0.000        0 (0.0%)           0.000           0.000
>  
> 0 open operations (pathname lookups)
> 0 dentry revalidates and 451 vfs lookup requests resulted in 451 LOOKUPs on the wire
> 0 vfs getdents calls resulted in 0 READDIRs on the wire
>  
>  
> I’m curious as to why the dentry revalidates and vfs lookups are itemized separately from the lookups.  I’ve been going through NFS and VFS documentation but don’t really know what I’m looking for.  I’ve learned what a dentry and vfs lookup are, as well as readdir and readdirplus, but  it just seems to me that the revalidates and vfs lookups that result in lookups on the wire are a different category for a good reason, and that’s why they’re broken out instead of just added to the lookups ops/sec.   Do you have documentation on these features which explains why they’re important to call out and track separately?

I'm not aware of any documentation. I thought Red Hat might
have put some together, but memory is fuzzy. You might have
a look at the discussion of the lookupcache mount option in
nfs(5) for a little context.

IIRC,

VFS lookup means the VFS layer is driving a ->lookup call
because it doesn't have a cached dentry.

Dentry revalidation means the VFS layer has a dentry and
wants to confirm with the filesystem that it is still
valid. Sometimes the client has unexpired attribute cache
data that can be used to avoid an on-the-wire operation
in this case.


> I think this is a clue for a performance issue we’ve been having, but I’m having trouble putting the threads together.
>  
> Thanks,
> Steven
> 
> DTCC DISCLAIMER: This email and any files transmitted with it are confidential and intended solely for the use of the individual or entity to whom they are addressed. If you have received this email in error, please notify us immediately and delete the email and any attachments from your system. The recipient should check this email and any attachments for the presence of viruses.  The company accepts no liability for any damage caused by any virus transmitted by this email.

--
Chuck Lever



