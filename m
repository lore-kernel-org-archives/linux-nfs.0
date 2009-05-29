From: Brian R Cowan <brcowan@us.ibm.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Fri, 29 May 2009 19:02:40 -0400
Message-ID: <OF2E297B0F.D51920EF-ON852575C5.007DAECF-852575C5.007E96C7@us.ibm.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>
	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com>	 <1243618968.7155.60.camel@heimdal.trondhjem.org>
	 <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>	 <1243620455.7155.80.camel@heimdal.trondhjem.org>
	 <OFA11F5AE0.259995DA-ON852575C5.0063C023-852575C5.00648F55@us.ibm.com>	 <1243621769.7155.97.camel@heimdal.trondhjem.org>
	 <OF65F0C005.770D6838-ON852575C5.006E0520-852575C5.006EC25F@us.ibm.com>	 <1243628519.7155.150.camel@heimdal.trondhjem.org>
	 <OFBB9B2C07.CC3D028B-ON852575C5. <1243634634.7155.160.camel@heimdal.trondhjem.org>
	 <OF061E0258.9581352B-ON852575C <1243636593.7155.188.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:58012 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbZE2XCl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 19:02:41 -0400
In-Reply-To: <1243636593.7155.188.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If you can explain how pulling that ONE change can cause the performance 
issue to essentially disappear, I'd be more than happy to *try* to get a 
2.6.30 test environment configured. Getting ClearCase to *install* on 
kernel.org kernels is a non-trivial operation, requiring modifications to 
install scripts, module makefiles, etc. Then there is the issue of 
verifying that nothing else is impacted, all before I can begin to do this 
test. We're talking days here. 

To be blunt, I'd need something I can take to a manager who will ask me 
why I'm spending so much time on an issue when we "already have the 
cause."

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
05/29/2009 06:38 PM
Subject:
Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing



On Fri, 2009-05-29 at 18:20 -0400, Brian R Cowan wrote:
> I am listening. 
> 
> Commit is sync. I get that.
> 
> The NFS client does Async writes in RHEL 4. They *eventually* get 
> committed. (Doesn't really matter who causes the commit, does it.)
> Read system calls may trigger cache flushing, but since not all of them 
> are sync writes, the reads don't *always* stall when cache flushes 
occur.
> Builds are fast. 

All reads that trigger writes will trigger _sync_ writes and _sync_
commits. That's true of RHEL-5, RHEL-4, RHEL-3, and all the way back to
the very first 2.4 kernels. There is no deferred commit in that case,
because the cached dirty data needs to be overwritten by a fresh read,
which means that we may lose the data if the server reboots between the
unstable write and the ensuing read.

> We do sync writes in RHEL 5, so they MUST stop and wait for the NFS 
server 
> to come back.
> READ system calls stall whan the read triggers a flush of one or more 
> cache pages.
> Builds are slow. Links are at least 4x slower.
> 
> I am perfectly willing to send you network traces showing the issue. I 
can 
> even DEMONSTRATE it for you using the remote meeting software of your 
> choice. I can even demonstrate the impact of removing that behavior.

Can you demonstrate it using a recent kernel? If it's a problem that is
limited to RHEL-5, then it is up to Peter & co to pull in the fixes from
mainline, but if the slowdown is still present in 2.6.30, then I'm all
ears. However I don't for a minute accept your explanation that this has
something to do with stable vs unstable+commit.

    Trond



