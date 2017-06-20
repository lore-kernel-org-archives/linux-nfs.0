Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40722 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751175AbdFTTlv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 15:41:51 -0400
Date: Tue, 20 Jun 2017 15:41:45 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
Message-ID: <20170620194145.GD13008@fieldses.org>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
 <20170616152254.14210.48071.stgit@klimt.1015granger.net>
 <1497693712.4684.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1497693712.4684.4.camel@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 17, 2017 at 06:01:52AM -0400, Jeff Layton wrote:
> This seems like the right thing to do, IMO. It's nice to avoid copies
> where we can, but this is just one of the places where we can't, at
> least with the way things stand now. It is a pity we don't have a way to
> CoW these things though.

We have to run all the data through CPU anyway for the checksum, so I
guess what I was thinking we could do--if we decided we needed the
optimization--was to figure out how to copy and checksum (or encrypt)
simultaneously in one pass.

--b.
