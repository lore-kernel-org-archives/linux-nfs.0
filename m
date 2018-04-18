Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:56474 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752568AbeDRHIo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2018 03:08:44 -0400
Date: Wed, 18 Apr 2018 00:08:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Steve Dickson <SteveD@RedHat.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180418070842.GC8764@infradead.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
 <1b45673f-516d-51ff-a1ef-8b07b9dd8619@RedHat.com>
 <1E0C45FE-2214-41FB-8634-1005CC13AD9E@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1E0C45FE-2214-41FB-8634-1005CC13AD9E@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 11:19:25AM -0400, Olga Kornievskaia wrote:
> Yes I agree. Let’s please decide if this will go in (with whatever code improvements are required) or let’s drop it.

Well, my vote is very clearly to drop it.
