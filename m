Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58882 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750781AbdCISkL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 13:40:11 -0500
Date: Thu, 9 Mar 2017 13:40:09 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170309184009.GD3929@fieldses.org>
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
> 
> > On Mar 9, 2017, at 11:17 AM, hch@infradead.org wrote:
> > 
> > On Thu, Mar 09, 2017 at 11:16:01AM -0500, bfields@fieldses.org
> > wrote:
> >> I guess I'm just hung up on the EINVAL vs. short copy behavior.  It
> >> seems more annoying and error-prone to be prepared for both, as
> >> opposed to trying clone and then explicitly falling back to copy if
> >> that doesn't work.  Maybe it's not that big a deal.
> > 
> > We can do short copies^H^H^H^H^Hclones for clone just as easily, at
> > least for local filesystems (NFS would require some tweaks due to
> > the protocol).
> 
> I’m confused by the wording of “we can do … easily” . Is “can” = in
> the future? Currently, testing copy_file_range() on a btfs with
> argument of offset+len beyond the end of the file fail with EINVAL. Is
> NFS tweaking = revert the “MUST” in the spec for the check? 

Checking https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41
... looks like the CLONE result doesn't even have a length.

Most users are probably cloning the whole file, so I guess it only
matters in the case the file's changing (so that the size returned from
stat might not be correct by the time you do the clone).

Allowing short copies would be one way to handle that--I think it'd work
then to just always request a clone to the maximum length.

Alternatively if the linux interface just had a way to say "clone to end
of file", that'd solve most of the problem and be a nice fit for the
existing NFS protocol (which special-cases length 0 to mean "to end of
file").

Maybe we could special-case the maximum size_t to mean that.  (What is
that, 2^63-1?.)

--b.
