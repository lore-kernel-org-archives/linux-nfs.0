Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60022 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170Ab2DLRHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Apr 2012 13:07:42 -0400
Date: Thu, 12 Apr 2012 13:07:39 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: global openowner_id and lockowner_id
Message-ID: <20120412170739.GB4684@fieldses.org>
References: <58E57AF8-1636-4017-93C0-8520488ED866@oracle.com>
 <1334245818.2237.55.camel@lade.trondhjem.org>
 <7212EB20-16EC-475E-993E-3F244C621AB0@oracle.com>
 <1334246326.2237.59.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334246326.2237.59.camel@lade.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 12, 2012 at 03:58:45PM +0000, Myklebust, Trond wrote:
> touch won't keep the file open. There is no open state once touch has
> finished executing.
> 
> What you have exposed above is a _server_ bug. The server is _not_
> allowed to assume that the client will cache an open owner forever once
> it no longer holds any open state using that open owner. We had a loong
> discussion about this on the mailing list a few years ago with David
> Robinson being the person who formulated the above rule.

Chuck, what server are you testing against?

I don't think the Linux server does the above, so it probably does need
fixing.

--b.
