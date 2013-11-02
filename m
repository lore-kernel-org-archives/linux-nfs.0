Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15888 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751744Ab3KBPCh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 11:02:37 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Bruce Fields <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Date: Sat, 2 Nov 2013 15:02:29 +0000
Message-ID: <38D14516-BAA4-45BB-8054-ED05AEC22C8F@netapp.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131028214030.GO31322@fieldses.org> <526FAF30.3060502@netapp.com>
 <20131029130649.GA29606@fieldses.org> <20131102135409.GC18961@infradead.org>
 <20131102144431.GB26983@fieldses.org> <20131102145105.GA4450@infradead.org>
In-Reply-To: <20131102145105.GA4450@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 2, 2013, at 10:51, Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Nov 02, 2013 at 10:44:31AM -0400, J. Bruce Fields wrote:
>> On Sat, Nov 02, 2013 at 06:54:09AM -0700, Christoph Hellwig wrote:
>>> On Tue, Oct 29, 2013 at 09:06:49AM -0400, J. Bruce Fields wrote:
>>>> What I meant was--why are we doing a sync at all, instead of returning
>>>> NFS_UNSTABLE and making the client commit?
>>> 
>>> Did NFSv4.2 introduce a concept of unstable metadata operations?
>> 
>> No, but I think WRITE_PLUS does have a stable/unstable bit so I think we
>> could choose not to do the sync if that'd make sense.
> 
> Both operations are idempotent, so supporting it shouldn't be a major
> obstactle.  But suddenly having some metadata operations that can be
> unstable seems like a major wart in the spec.

COMMIT has always had a metadata part to it, though. It guarantees stability of the ctime/mime and change attributes in addition to the file size and data.

IOW: it really is more akin to fsync() than to fdatasync().

Cheers
  Trond