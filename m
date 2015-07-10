Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932407AbbGJOSr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 10:18:47 -0400
Date: Fri, 10 Jul 2015 10:18:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 5/5] svcrdma: Boost NFS READ/WRITE payload size maximum
Message-ID: <20150710141846.GB31121@fieldses.org>
References: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
 <20150709204546.8481.65857.stgit@klimt.1015granger.net>
 <20150710141814.GA31121@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150710141814.GA31121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 10:18:14AM -0400, J. Bruce Fields wrote:
> On Thu, Jul 09, 2015 at 04:45:47PM -0400, Chuck Lever wrote:
> > Increased to 1 megabyte.
> 
> Why not more or less?
> 
> Why do we even have this constant, why shouldn't we just use
> RPCSVC_MAXPAYLOAD?

(That one question aside these look fine, I'll apply unless I hear
otherwise.)

--b.
