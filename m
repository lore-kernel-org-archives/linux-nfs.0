Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42688 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866Ab2CMV5r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 17:57:47 -0400
Date: Tue, 13 Mar 2012 17:57:45 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Anton Starikov <ant.starikov@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS4 without id mapper
Message-ID: <20120313215744.GA23853@fieldses.org>
References: <66B6E4EA-A94C-4FD9-87C1-A110B0AB3D71@gmail.com>
 <1331659764.3419.23.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1331659764.3419.23.camel@lade.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2012 at 05:29:24PM +0000, Myklebust, Trond wrote:
> On Tue, 2012-03-13 at 17:21 +0100, Anton Starikov wrote:
> > Hi,
> > 
> > I have probably stupid question, but is there a way to use NFS-4 in old-fashoned way without any idmapper involved? Assuming setup with auth=sys/none and no root squash.
> 
> The Linux client can do it, but not the Linux server. Sorry...

I did finally start looking at this, so hopefully the server side should
be cooperating as well soon.

--b.
