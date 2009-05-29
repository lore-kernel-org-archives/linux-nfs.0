From: Brian R Cowan <brcowan@us.ibm.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Fri, 29 May 2009 18:20:40 -0400
Message-ID: <OF061E0258.9581352B-ON852575C5.0079D9DB-852575C5.007ABE66@us.ibm.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com>
	 <1243618968.7155.60.camel@heimdal.trondhjem.org>	 <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>
	 <1243620455.7155.80.camel@heimdal.trondhjem.org>	 <OFA11F5AE0.259995DA-ON852575C5.0063C023-852575C5.00648F55@us.ibm.com>
	 <1243621769.7155.97.camel@heimdal.trondhjem.org>	 <OF65F0C005.770D6838-ON852575C5.006E0520-852575C5.006EC25F@us.ibm.com>
	 <1243628519.7155.150.camel@heimdal.trondhjem.org>	 <OFBB9B2C07.CC3D028B-ON852575C5. <1243634634.7155.160.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36204 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031AbZE2WUl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 18:20:41 -0400
In-Reply-To: <1243634634.7155.160.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am listening. 

Commit is sync. I get that.

The NFS client does Async writes in RHEL 4. They *eventually* get 
committed. (Doesn't really matter who causes the commit, does it.)
Read system calls may trigger cache flushing, but since not all of them 
are sync writes, the reads don't *always* stall when cache flushes occur.
Builds are fast. 

We do sync writes in RHEL 5, so they MUST stop and wait for the NFS server 
to come back.
READ system calls stall whan the read triggers a flush of one or more 
cache pages.
Builds are slow. Links are at least 4x slower.

I am perfectly willing to send you network traces showing the issue. I can 
even DEMONSTRATE it for you using the remote meeting software of your 
choice. I can even demonstrate the impact of removing that behavior.

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
05/29/2009 06:06 PM
Subject:
Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing



On Fri, 2009-05-29 at 17:55 -0400, Brian R Cowan wrote:
> So, it is possible that either pdflush is sending the commits or us, or 
> that the commits are happening when the file closes, giving us one/tens 
of 
> commits instead of hundreds or thousands. That's a big difference. The 
> write RPCs still happen in RHEL 4, they just don't block the linker, or 
at 
> least nowhere near as often. Since there is only one application/thread 
> (the gcc linker) writing this file, the odds of another task getting 
> stalled here are minimal at best.

No, you're not listening! That COMMIT is _synchronous_ and happens
before you can proceed with the READ request. There is no economy of
scale as you seem to assume.

Trond




