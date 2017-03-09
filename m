Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:54422 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754150AbdCIWwL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 17:52:11 -0500
Date: Thu, 9 Mar 2017 13:55:56 -0800
From: "hch@infradead.org" <hch@infradead.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170309215556.GA22756@infradead.org>
References: <20170308195327.GA3492@fieldses.org>
 <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
 <1489004308.3098.10.camel@primarydata.com>
 <20170308203236.GC3492@fieldses.org>
 <1489006194.3098.12.camel@primarydata.com>
 <20170309152948.GB3929@fieldses.org>
 <20170309153559.GA20205@infradead.org>
 <20170309161601.GC3929@fieldses.org>
 <20170309161729.GA11655@infradead.org>
 <480EF075-69E6-458D-AA5F-FBE19F68C3C3@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <480EF075-69E6-458D-AA5F-FBE19F68C3C3@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 09, 2017 at 12:28:03PM -0500, Olga Kornievskaia wrote:
> I’m confused by the wording of “we can do … easily” . Is “can” = in the future? Currently, testing copy_file_range() on a btfs with argument of offset+len beyond the end of the file fail with EINVAL. Is NFS tweaking = revert the “MUST” in the spec for the check? 

The current clone and copy documents (which are our specs) require
this behavior, so that is expected.  But if we decided we want a variant
of copy / clone that doesn't do this it would be very easy to implement
in the local file systems.  Only for NFS we'd get a failure back and
would have to retry the clone based on the updated file size.
