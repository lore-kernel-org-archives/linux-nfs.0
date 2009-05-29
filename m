From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 19:13:09 -0400
Message-ID: <1243638789.7155.194.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>
	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com>
	 <1243618968.7155.60.camel@heimdal.trondhjem.org>
	 <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>
	 <1243620455.7155.80.camel@heimdal.trondhjem.org>
	 <OFA11F5AE0.259995DA-ON852575C5.0063C023-852575C5.00648F55@us.ibm.com>
	 <1243621769.7155.97.camel@heimdal.trondhjem.org>
	 <OF65F0C005.770D6838-ON852575C5.006E0520-852575C5.006EC25F@us.ibm.com>
	 <1243628519.7155.150.camel@heimdal.trondhjem.org>
	 <OFBB9B2C07.CC3D028B-ON852575C5. <1243634634.7155.160.camel@heimdal.trondhjem.org>
	 <OF061E0258.9581352B-ON852575C <1243636593.7155.188.camel@heimdal.trondhjem.org>
	 <OF2E297B0F.D51920EF-ON852575C5.007DAECF-852575C5.007E96C7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Brian R Cowan <brcowan@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:38504 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbZE2XNP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 19:13:15 -0400
In-Reply-To: <OF2E297B0F.D51920EF-ON852575C5.007DAECF-852575C5.007E96C7@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-29 at 19:02 -0400, Brian R Cowan wrote:
> If you can explain how pulling that ONE change can cause the performance 
> issue to essentially disappear, I'd be more than happy to *try* to get a 
> 2.6.30 test environment configured. Getting ClearCase to *install* on 
> kernel.org kernels is a non-trivial operation, requiring modifications to 
> install scripts, module makefiles, etc. Then there is the issue of 
> verifying that nothing else is impacted, all before I can begin to do this 
> test. We're talking days here. 
> 
> To be blunt, I'd need something I can take to a manager who will ask me 
> why I'm spending so much time on an issue when we "already have the 
> cause."

It's simple: you are the one asking for a change to the established
kernel behaviour, so you get to justify that change. Saying "it breaks
clearcase on RHEL-5" is not a justification, and I won't accept to ack
the change.

Trond

