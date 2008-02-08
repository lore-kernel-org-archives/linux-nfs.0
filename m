From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 08 Feb 2008 10:18:03 -0500
Message-ID: <1202483883.10337.2.camel@heimdal.trondhjem.org>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
	 <1202483596.8914.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:39970 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbYBHPSG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 10:18:06 -0500
In-Reply-To: <1202483596.8914.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-02-08 at 10:13 -0500, Trond Myklebust wrote:

> So whereas I agree that it might be correct to flag a READDIR reply that
> contains no entries due to XDR encoding bugs, I'm not sure that we
> should be flagging errors in the case where the XDR is correct.

Another useful error change in the readdir code is that we may consider
flagging an ENAMETOOLONG error instead of EIO in the cases where the
filename is too large for us to parse.

Trond

