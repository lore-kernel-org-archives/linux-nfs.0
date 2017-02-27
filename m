Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa12-07.prod.phx3.secureserver.net ([68.178.252.236]:39722
        "EHLO p3plsmtpa12-07.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751666AbdB0MRy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2017 07:17:54 -0500
Subject: Re: [PATCH v2 0/4] nfs/nfsd/sunrpc: enforce NFSv4 transport
 requirements
To: Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170224182525.10390-1-jlayton@redhat.com>
 <20170224212516.GH26378@fieldses.org> <1487972064.3314.8.camel@redhat.com>
 <20170224214442.GI26378@fieldses.org> <1488196763.2876.1.camel@redhat.com>
Cc: trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        jgunthorpe@obsidianresearch.com
From: Tom Talpey <tom@talpey.com>
Message-ID: <2c8602da-5e1b-a7d1-b03b-2a06442450f9@talpey.com>
Date: Mon, 27 Feb 2017 07:08:00 -0500
MIME-Version: 1.0
In-Reply-To: <1488196763.2876.1.camel@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/27/2017 6:59 AM, Jeff Layton wrote:
> What we'd need to make that happen, I think is a [global] stanza in
> nfs.conf with a single 'nfsd_v3' boolean that defaults to off. If

Don't forget v2! And maybe even v4.0 if you're encouraging non-legacy
operation. RFC3530 was published 14 years ago, btw. RFC1813 in 1995,
and RFC1094 in 1989.
