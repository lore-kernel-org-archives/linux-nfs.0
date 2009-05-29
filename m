From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 18:03:54 -0400
Message-ID: <1243634634.7155.160.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>
	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com>
	 <1243618968.7155.60.camel@heimdal.trondhjem.org>
	 <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>
	 <1243620455.7155.80.camel@heimdal.trondhjem.org>
	 <OFA11F5AE0.259995DA-ON852575C5.0063C023-852575C5.00648F55@us.ibm.com>
	 <1243621769.7155.97.camel@heimdal.trondhjem.org>
	 <OF65F0C005.770D6838-ON852575C5.006E0520-852575C5.006EC25F@us.ibm.com>
	 <1243628519.7155.150.camel@heimdal.trondhjem.org>
	 <OFBB9B2C07.CC3D028B-ON852575C5.007369D7-852575C5.00786705@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Brian R Cowan <brcowan@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60071 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbZE2WEA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 18:04:00 -0400
In-Reply-To: <OFBB9B2C07.CC3D028B-ON852575C5.007369D7-852575C5.00786705@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-29 at 17:55 -0400, Brian R Cowan wrote:
> So, it is possible that either pdflush is sending the commits or us, or 
> that the commits are happening when the file closes, giving us one/tens of 
> commits instead of hundreds or thousands. That's a big difference. The 
> write RPCs still happen in RHEL 4, they just don't block the linker, or at 
> least nowhere near as often. Since there is only one application/thread 
> (the gcc linker) writing this file, the odds of another task getting 
> stalled here are minimal at best.

No, you're not listening! That COMMIT is _synchronous_ and happens
before you can proceed with the READ request. There is no economy of
scale as you seem to assume.

Trond


