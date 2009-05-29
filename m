From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 14:07:35 -0400
Message-ID: <1243620455.7155.80.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>
	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com>
	 <1243618968.7155.60.camel@heimdal.trondhjem.org>
	 <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Brian R Cowan <brcowan@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38998 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753469AbZE2SHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 14:07:39 -0400
In-Reply-To: <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-29 at 13:55 -0400, Brian R Cowan wrote:
> > Yes. If the page is dirty, but not up to date, then it needs to be
> > cleaned before you can overwrite the contents with the results of a
> > fresh read.
> > That means flushing the data to disk... Which again means doing either a
> > stable write or an unstable write+commit. The former is more efficient
> > that the latter, 'cos it accomplishes the exact same work in a single
> > RPC call.
> 
> I suspect that the COMMIT RPC's are done somewhere other than in the flush 
> itself. If the "write + commit" operation was happening in the that exact 
> matter, then the change in the git at the beginning of this thread *would 
> not have impacted client performance*. I can demonstrate -- at will -- 
> that it does impact performance. So, there is something that keeps track 
> of the number of writes and issues the commits without slowing down the 
> application. This git change bypasses that and degrades the linker 
> performance.

If the server gives slower performance for a single stable write, vs.
the same unstable write + commit, then you are demonstrating that the
server is seriously _broken_.

The only other explanation, is if the client prior to that patch being
applied was somehow failing to send out the COMMIT. If so, then the
client was broken, and the patch is a fix that results in correct
behaviour. That would mean that the rest of the client flush code is
probably still broken, but at least the nfs_wb_page() is now correct.

Those are the only 2 options.

Trond

