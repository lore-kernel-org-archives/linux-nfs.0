Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:56226 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932091AbeDCMKh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Apr 2018 08:10:37 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: fstests@vger.kernel.org, "Scott Mayhew" <smayhew@redhat.com>,
        "Anna Schumaker" <Anna.Schumaker@Netapp.com>,
        "Chuck Lever" <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
Date: Tue, 03 Apr 2018 08:10:36 -0400
Message-ID: <DA98114C-755B-4DA2-B188-3C6E27A44E93@redhat.com>
In-Reply-To: <20180403094540.GA2254@infradead.org>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
 <20180403094540.GA2254@infradead.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3 Apr 2018, at 5:45, Christoph Hellwig wrote:

> On Thu, Mar 29, 2018 at 11:34:39AM -0400, Benjamin Coddington wrote:
>> We'd like to run generic tests for NFS, but often have slightly different
>> output for our results.  One instance is that for the NFS client the
>> removal of an open file or directory is handled differently than for a
>> local filesystem.  We can expect nlink to be 1 for files, and to receive
>> -ESTALE for operations on deleted directories, isn't that silly?
>
> NFS is simply buggy in this case, and we should at least xfail the test
> case, not make it look fine.

No, having nlink == 1 is not a bug and we should expect that behavior, the
same with the -ESTALE return for a directory.  This is true, at least, for
the linux client.

> I'd rather have a file that lists expected fails per file system with an
> explanation than a hack like this that papers over the issue.

I'd like that as well, since there are a number of tests that just don't
make sense at all for NFS..  I'll figure out a way to do that.  We have
groups of tests right now, and NFS is one, but those seem to be tests that
should be run only by NFS.

Ben
