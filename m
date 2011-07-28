Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab1G1VsO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 17:48:14 -0400
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Gregory Magoon <gmagoon@MIT.EDU>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 28 Jul 2011 17:47:57 -0400
In-Reply-To: <20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu>
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
	 <1311886684.27285.8.camel@lade.trondhjem.org>
	 <20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311889677.27285.14.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-07-28 at 17:24 -0400, Gregory Magoon wrote: 
> Thanks for the tips...unfortunately, making the changes you suggest (removing
> timeo, rsize, wsize options) doesn't seem to address the issue with MPICH2 and
> NFSv4.

Have you turned off delegations on the server? I wouldn't expect them to
help much on an MPI workload.

Otherwise, you might want to post a comparison of your results from
'nfsstat' for your workload on NFSv3 and NFSv4.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

