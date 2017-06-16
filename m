Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32974 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752886AbdFPRw7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 13:52:59 -0400
Date: Fri, 16 Jun 2017 13:52:53 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
Message-ID: <20170616175253.GF12030@fieldses.org>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
 <20170616152254.14210.48071.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170616152254.14210.48071.stgit@klimt.1015granger.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just repeating some comments from the bug:

On Fri, Jun 16, 2017 at 11:22:54AM -0400, Chuck Lever wrote:
> Running a multi-threaded 8KB fio test (70/30 mix), three or four out
> of twelve of the jobs fail when using krb5i. The failure is an EIO
> on a read.
> 
> Troubleshooting confirmed the EIO results when the client fails to
> verify the MIC of an NFS READ reply. Bruce suggested the problem
> could be due to the data payload changing between the time the
> reply's MIC was computed on the server and the time the reply was
> actually sent.
> 
> krb5p gets around this problem by disabling RQ_SPLICE_OK.

And you verified that this does fix the problem in your case.

So, I think it's a simple fix and probably the best we can do without a
lot more work, so I'm happy applying it.

That said, I'm still curious about the performance:

> I would say that there is not much difference in this test.

We added an extra copy to the read path and it didn't seem to affect
throughput of streaming read much--I think that just says memory
bandwidth isn't the bottlneck in this case?  Which doesn't seem too
surprising.

I wonder what we should be looking for--maybe running the same test but
also measuring CPU usage somehow.

--b.
