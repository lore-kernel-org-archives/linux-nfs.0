Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:1381 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754783AbbIHPII (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2015 11:08:08 -0400
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
To: Al Viro <viro@ZenIV.linux.org.uk>, Andreas Dilger <adilger@dilger.ca>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <4B41043F-5D85-42D6-8F20-2DCC45930EF4@dilger.ca>
 <20150905083342.GG22011@ZenIV.linux.org.uk>
CC: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <clm@fb.com>, <darrick.wong@oracle.com>,
        <mtk.manpages@gmail.com>, <andros@netapp.com>, <hch@infradead.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55EEF9D3.6050505@Netapp.com>
Date: Tue, 8 Sep 2015 11:08:03 -0400
MIME-Version: 1.0
In-Reply-To: <20150905083342.GG22011@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/05/2015 04:33 AM, Al Viro wrote:
> On Fri, Sep 04, 2015 at 04:25:27PM -0600, Andreas Dilger wrote:
> 
>> This is a bit of a surprising result, since in my testing in the
>> past, copy_{to/from}_user() is a major consumer of CPU time (50%
>> of a CPU core at 1GB/s).  What backing filesystem did you test on?
> 
> While we are at it, was cp(1) using read(2)/write(2) loop or was it using
> something else (sendfile(2), for example)?

cp uses a read / write loop, and has some heuristics for guessing an optimum buffer size.

Anna

> 

