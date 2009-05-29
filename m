From: Brian R Cowan <brcowan@us.ibm.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Fri, 29 May 2009 17:55:06 -0400
Message-ID: <OFBB9B2C07.CC3D028B-ON852575C5.007369D7-852575C5.00786705@us.ibm.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com>
	 <1243618968.7155.60.camel@heimdal.trondhjem.org>	 <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>
	 <1243620455.7155.80.camel@heimdal.trondhjem.org>	 <OFA11F5AE0.259995DA-ON852575C5.0063C023-852575C5.00648F55@us.ibm.com>
	 <1243621769.7155.97.camel@heimdal.trondhjem.org>	 <OF65F0C005.770D6838-ON852575C5.006E0520-852575C5.006EC25F@us.ibm.com> <1243628519.7155.150.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:56611 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbZE2VzG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 17:55:06 -0400
In-Reply-To: <1243628519.7155.150.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So, it is possible that either pdflush is sending the commits or us, or 
that the commits are happening when the file closes, giving us one/tens of 
commits instead of hundreds or thousands. That's a big difference. The 
write RPCs still happen in RHEL 4, they just don't block the linker, or at 
least nowhere near as often. Since there is only one application/thread 
(the gcc linker) writing this file, the odds of another task getting 
stalled here are minimal at best.

This optimization definitely helps server utilization for copies of large 
numbers of small files, and I personally don't care which is the default 
(though I have a coworker who is of the opinion that async means async, 
and if he wanted sync writes, he would either mount with nfsvers=2 or 
mount sync). But we need the option to turn it off for cases where it is 
thought to cause problems. 

You mention that one can set the async export option, but 1) it may not 
always available; and 2) essentially tells the server to "lie" about write 
status, something that can bite us seriously if the server crashes, hits a 
disk full error. etc. And in any event, it's something that only a 
particular class of clients is impacted by, and making a change to *all* 
so *some* work in the expected manner feels about as graceful as dynamite 
fishing...

=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Customer Advocacy Group (CAG)
Rational Software
IBM Software Group
81 Hartwell Ave
Lexington, MA
 
Phone: 1.781.372.3580
Web: http://www.ibm.com/software/rational/support/
 

Please be sure to update your PMR using ESR at 
http://www-306.ibm.com/software/support/probsub.html or cc all 
correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
case I am not available.



From:
Trond Myklebust <trond.myklebust@fys.uio.no>
To:
Brian R Cowan/Cupertino/IBM@IBMUS
Cc:
Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org, 
linux-nfs-owner@vger.kernel.org, Peter Staubach <staubach@redhat.com>
Date:
05/29/2009 04:28 PM
Subject:
Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing



On Fri, 2009-05-29 at 16:09 -0400, Brian R Cowan wrote:
> I think you missed the context of my comment... Previous to this 
> 4-year-old update, the writes were not sent with STABLE, this update 
> forced that behavior. So, before then we sent an UNSTABLE write request. 

> This would either give us back the UNSTABLE or FILE_SYNC response. My 
> question is this: When the server sends back UNSTABLE, as a response to 
> UNSTABLE, exactly what happens? By some chance is there a separate 
worker 
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



