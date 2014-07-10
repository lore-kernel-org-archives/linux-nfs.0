Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbaGJStt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 14:49:49 -0400
Date: Thu, 10 Jul 2014 14:49:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: swise@ogc.net, Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 2/2] svcrdma: Remove extra writeargs sanity check for
 NFSv2/3
Message-ID: <20140710184948.GC26561@fieldses.org>
References: <20140710174225.3734.44692.stgit@klimt.1015granger.net>
 <20140710174435.3734.69638.stgit@klimt.1015granger.net>
 <20140710181944.GB26561@fieldses.org>
 <3BA364F8-E5ED-45A1-8662-E5F91AA7AF0A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <3BA364F8-E5ED-45A1-8662-E5F91AA7AF0A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 02:24:57PM -0400, Chuck Lever wrote:
> 
> On Jul 10, 2014, at 2:19 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Thu, Jul 10, 2014 at 01:44:35PM -0400, Chuck Lever wrote:
> >> The server should comply with RFC 5667,
> > 
> > Where's the relevant language?  (I took a quick look but didn't see it.)
> 
> Sorry, I listed the wrong RFC when I wrote the description of bug 246.
> It’s actually RFC 5666, section 3.7.

Thanks.

> > So I think you just want to drop the round-up of len, not the whole
> > check.
> 
> I’ll try that, thanks!

Actually, I'd really rather this get fixed up in the rpc layer.  The
padding is really required for correct xdr.  The fact that RDMA doesn't
require those zeroes to be literally transmitted across the network
sounds like a transport-level detail that should be hidden from the xdr
code.

--b.
