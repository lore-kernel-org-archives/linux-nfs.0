Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8537 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751232AbeDQRlN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 13:41:13 -0400
Date: Tue, 17 Apr 2018 13:41:11 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180417174111.GK10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <20180417150002.GF10291@parsley.fieldses.org>
 <23541B87-1142-4B59-BD57-F572FB8C1C4A@netapp.com>
 <20180417154106.GG10291@parsley.fieldses.org>
 <20180417155829.GH10291@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180417155829.GH10291@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 11:58:29AM -0400, J. Bruce Fields wrote:
> So, could we just have a global run-time configuration option?  Maybe a
> module parameter, defaulting to off.

Also if we do that I don't think we'd really need a build-time
configuration option any more.

--b.
