Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39872 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbaJON0W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Oct 2014 09:26:22 -0400
Date: Wed, 15 Oct 2014 06:26:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve French <smfrench@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Anna.Schumaker@netapp.com,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 xfstests results
Message-ID: <20141015132620.GB10652@infradead.org>
References: <20140917181619.GA31483@infradead.org>
 <CAH2r5mutD=JzAf0whP2OLgZVzBR_H81-rzmq_Qku2fEBofR9mA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5mutD=JzAf0whP2OLgZVzBR_H81-rzmq_Qku2fEBofR9mA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 14, 2014 at 07:49:10PM -0500, Steve French wrote:
> Is the test 35 failure (overwriting rename syscall test) expected (it
> wasn't in Christoph's original list)? and the test 11 failure expected
> (which failed on NFSv4 only)?
> 
> Test 35 output:
>     --- tests/generic/035.out 2014-10-14 16:59:22.237529380 -0500
>     +++ /home/sfrench/xfstests/results//NFSv41/generic/035.out.bad
> 2014-10-14 18:52:51.523146653 -0500
>     @@ -1,3 +1,6 @@
>      QA output created by 035
>      overwriting regular file:
>     +./tests/generic/035: line 57: src/t_rename_overwrite: No such
> file or directory

Looks like you didn't run a make to build that new testcase.

