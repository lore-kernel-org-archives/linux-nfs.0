Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gw1a.telemetry-investments.com ([64.20.161.180]:33093 "EHLO
	sv1.telemetry-investments.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754369Ab0LJWaj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 17:30:39 -0500
Date: Fri, 10 Dec 2010 17:30:29 -0500
From: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Subject: Re: proposed patch to rpcbind to provide finer-grained security
 controls than offered by the -i option
Message-ID: <20101210223029.GA24016@ti93.telemetry-investments.com>
References: <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com>
 <4D016F44.3020002@RedHat.com>
 <20101210023847.GB15344@ti93.telemetry-investments.com>
 <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com>
 <4D024D70.7040108@RedHat.com>
 <FD9D05EF-FB57-45FB-BBDC-38E3B92D54AA@oracle.com>
 <20101210171014.GA5280@ti93.telemetry-investments.com>
 <0F5A7F8B-AA38-4653-BCDC-B192FF790F51@oracle.com>
 <20101210215758.GA15059@ti93.telemetry-investments.com>
 <56D846C6-C941-4ACC-9A8B-DFDC9296C2CE@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56D846C6-C941-4ACC-9A8B-DFDC9296C2CE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 10, 2010 at 05:22:43PM -0500, Chuck Lever wrote:
> Thanks for the report.  We are aware of a handful of other minor instances, so it is true that there is not full ABI compatibility.  For most RPC applications of sufficient complexity, the differences are not significant.  At a guess, the use of RPCL and rpcgen to construct your XDR type might be helpful for avoiding this problem.

I'm not expert in rpcgen, but doubt that it's helpful for a low-level library
implementing a new XDR type.  I scanned the man page and don't see any relevant
features.  In any case, I agree that the vast majority of code would not be
mucking around with implementing XDR backends; in my case, I wanted a
scatter/gather memory implementation to avoid some needless copies.

> The XDR struct is not part of the published RPC API, is it?  See Sun doc 816-1435.

I'm sure you are correct.  My point is only that the libtirpc implementation is
not 100% compatible with glibc, so deleting the glibc implementation may cause
trouble for some (very) small subset of applications.  I would still recommend
as a first step flagging the legacy interface as deprecated in the
/usr/include/rpc/*.h header files and directing people to use the new API.

Regards,
Andy
