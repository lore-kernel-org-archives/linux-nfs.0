Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43780 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752812AbeDQP6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 11:58:31 -0400
Date: Tue, 17 Apr 2018 11:58:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180417155829.GH10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <20180417150002.GF10291@parsley.fieldses.org>
 <23541B87-1142-4B59-BD57-F572FB8C1C4A@netapp.com>
 <20180417154106.GG10291@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180417154106.GG10291@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So, could we just have a global run-time configuration option?  Maybe a
module parameter, defaulting to off.

Then an admin can decide to turn it on, or to turn it on only after
installing some firewall rules to restrict the source of copies.

Another odd option might be to restrict to copies from files on
filesystems that server already has mounted.  Maybe that would simplify
the copy code too.  I think that's too inflexible, though.

--b.
