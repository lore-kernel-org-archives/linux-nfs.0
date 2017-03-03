Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:60520 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdCCRXE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 12:23:04 -0500
Date: Fri, 3 Mar 2017 07:14:10 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Cc: linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-ima-devel@lists.sourceforge.net,
        linux-security-module@vger.kernel.org,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
        James Morris <james.l.morris@oracle.com>, kernel@pengutronix.de
Subject: Re: IMA on NFS deadlocks since a5864c999de670
Message-ID: <20170303151410.GA7751@infradead.org>
References: <20170303103838.tnprd3pww4jmippp@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170303103838.tnprd3pww4jmippp@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 03, 2017 at 11:38:51AM +0100, Sascha Hauer wrote:
> Right now I have no idea if this commit is breaking things or if IMA
> is the guilty one and this commit only triggers it.

IMA is unfortunately completely broken, and it has the same issue
on XFS and OCFS2 for example.
