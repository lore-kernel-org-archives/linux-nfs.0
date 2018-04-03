Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:51920 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932112AbeDCMgg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Apr 2018 08:36:36 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: fstests@vger.kernel.org, "Scott Mayhew" <smayhew@redhat.com>,
        "Anna Schumaker" <Anna.Schumaker@Netapp.com>,
        "Chuck Lever" <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
Date: Tue, 03 Apr 2018 08:36:35 -0400
Message-ID: <5987BE75-EB3E-48CA-8968-92EBC962435C@redhat.com>
In-Reply-To: <20180403122531.GA30598@infradead.org>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
 <20180403094540.GA2254@infradead.org>
 <DA98114C-755B-4DA2-B188-3C6E27A44E93@redhat.com>
 <20180403122531.GA30598@infradead.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3 Apr 2018, at 8:25, Christoph Hellwig wrote:

> On Tue, Apr 03, 2018 at 08:10:36AM -0400, Benjamin Coddington wrote:
>> No, having nlink == 1 is not a bug and we should expect that behavior, the
>> same with the -ESTALE return for a directory.  This is true, at least, for
>> the linux client.
>
> In terms of Linux semantics is plain and simple is a bug.  It is an
> expected bug in NFS, but that doesn't make it correct.

Ok yes.  I'd still like to test for it, since it's possible we can get this
wrong.  Maybe a better approach is to copy this one to an NFS-only test,
with the expected buggy output, and then everything in generic/ can go back
to not having any output overrides.

That keeps us from setting a precedent that any generic/ tests may be
papered over, rather than expected to fail for a particular file system.

Ben
