From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 16:21:59 -0400
Message-ID: <1243628519.7155.150.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
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
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Brian R Cowan <brcowan@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38711 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932231AbZE2UWL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 16:22:11 -0400
In-Reply-To: <OF65F0C005.770D6838-ON852575C5.006E0520-852575C5.006EC25F@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-29 at 16:09 -0400, Brian R Cowan wrote:
> I think you missed the context of my comment... Previous to this 
> 4-year-old update, the writes were not sent with STABLE, this update 
> forced that behavior. So, before then we sent an UNSTABLE write request. 
> This would either give us back the UNSTABLE or FILE_SYNC response. My 
> question is this: When the server sends back UNSTABLE, as a response to 
> UNSTABLE, exactly what happens? By some chance is there a separate worker 
> thread that occasionally sends COMMITs back to the server?

pdflush will do it occasionally, but otherwise the COMMITs are all sent
synchronously by the thread that is flushing out the data.

In this case, the flush is done by the call to nfs_wb_page() in
nfs_readpage(), and it waits synchronously for the unstable WRITE and
the subsequent COMMIT to finish.

Note that there is no way to bypass the wait: if some other thread jumps
in and sends the COMMIT (after the unstable write has returned), then
the caller of nfs_wb_page() still has to wait for that call to complete,
and for nfs_commit_release() to mark the page as clean.

Trond

