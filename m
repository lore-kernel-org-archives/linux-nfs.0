Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp04.blacknight.com ([81.17.249.35]:41297 "EHLO
	outbound-smtp04.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754128AbbEZQn3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 12:43:29 -0400
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 1A4649848B
	for <linux-nfs@vger.kernel.org>; Tue, 26 May 2015 16:43:22 +0000 (UTC)
Message-ID: <5564A2A9.80402@mpstor.com>
Date: Tue, 26 May 2015 17:43:21 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com> <20150515192037.GB29627@fieldses.org> <555CB5EE.2@mpstor.com> <555CD2F0.6080408@mpstor.com> <20150525151310.GA18386@infradead.org>
In-Reply-To: <20150525151310.GA18386@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25/05/15 16:13, Christoph Hellwig wrote:
> On Wed, May 20, 2015 at 07:31:12PM +0100, Benjamin ESTRABAUD wrote:
>> After 25 iterations (after creating a 25GiB file, for a cumulative total of
>> 325GiB if including the testfile.1G -> testfile.24G) the issue occured
>> again. The IO rate to the SAN LUN dropped severely to a real 3MiB/sec
>> (measured at the SAN LUN block device level).
>>
>> Also I've noticed that a kernel process is taking up 100% of one core at
>> least:
>>
>> 516 root      20   0       0      0      0 R 100.0  0.0  11:09.72
>> kworker/u49:4
>
Hi Christoph,

> Can you send me the output of "perf record -ag" for that run?
>
I ran "perf record -ag" on the pNFS client and "trace-cmd record -e 
nfsd" (it seems to capture all layout* tracepoints) on the pNFS server 
(I figured there was no need to run it on the client, and anyways the 
trace wound up empty when I tried).

I then ran "dd if=/dev/zero of=/mnt/pnfs1/testfile.26G bs=1M 
count=26624" on the client (writing a 26GB file), waited about 20 
seconds for the kworker issue to happen (it never happens immediately) 
and as soon as it started, waited another 10 seconds so that the trace 
has enough data to debug with.

All those three commands (perf record, trace-cmd and dd) where run 
within a 3-4 seconds window, so there should be not much "junk" perf 
trace at the beginning which has nothing to do with NFS.

Here's the link to the compressed perf record -ag+trace-cmd outputs (let 
me know if you need to use a different host provider than dropbox):

https://www.dropbox.com/s/wou3hqb2go21gbw/traces.tar.gz?dl=0

> Also can you send the output from trace-cmd for tracing all nfsd.layout*
> tracepoints for such a run?
>
>> Would the 25GiB figure ring any bells to you? Would there be a way for me to
>> identify this workqueue (figure out if it is pNFS related)?
>
> Perf record should help by looking at the cycles spent.
>

Thanks a lot for your help!

Regards,
Ben.
