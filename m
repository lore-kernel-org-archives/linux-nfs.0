From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: The next step: nfsvers=4
Date: Thu, 19 Mar 2009 14:41:36 -0400
Message-ID: <49c29203.85c2f10a.098d.17b5@mx.google.com>
References: <49C2704F.5050303@RedHat.com>
 <7A24DF798E223B4C9864E8F92E8C93EC026043D3@SACMVEXC1-PRD.hq.netapp.com>
 <855593AD-7541-443F-BA92-491EC32FEDFB@oracle.com>
 <49C28201.1020301@panasas.com>
 <1FF921B7-4A44-49D7-8E01-1DAC5D18C1AB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Benny Halevy <bhalevy@panasas.com>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:42374 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbZCSSmO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2009 14:42:14 -0400
Received: by qw-out-2122.google.com with SMTP id 8so567289qwh.37
        for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2009 11:42:11 -0700 (PDT)
In-Reply-To: <1FF921B7-4A44-49D7-8E01-1DAC5D18C1AB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:13 PM 3/19/2009, Chuck Lever wrote:
>On Mar 19, 2009, at Mar 19, 2009, 1:33 PM, Benny Halevy wrote:
>> I think that if no version is specified all versions that
>> the client supports should be tried, highest first.
>> Otherwise mount.nfs should try only the specified version.
>
>One nit is that the set of mount options supported by nfs4 is  
>different than the set supported by nfs.  clientaddr= is supported by  
>nfs4, but not by nfs, for example.  I believe that nocto is not  
>supported by nfs4.  The mountproto option is only supported by nfs.
>
>If no vers= is specified and only NFSv4 is available on the server,  
>but something like "nocto" shows up on the command line mount options,  
>do we:
>
>a) fail the mount, or
>b) ignore the nocto option
>
>a) seems like the least surprising behavior.

I think the "sloppy" option might be relevant here too.

While we're on the subject of sloppy, what about the automounter?
It has always been an issue to deploy automounter maps which are
shared by diverse client populations - there are significant issues
for older Linux clients, and newer Solaris ones for that matter, with
NFSv4.

I would strongly suggest touching and/or changing as few options as
possible, and paying close attention to the results with legacy or
generic configurations on new kernels. The more lenient, the better
IMO, except where specific options require specific actions.

Tom.

