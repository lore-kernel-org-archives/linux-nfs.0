Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33070 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750787AbdFPSmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 14:42:08 -0400
Date: Fri, 16 Jun 2017 14:42:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
Message-ID: <20170616184208.GH12030@fieldses.org>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
 <20170616152254.14210.48071.stgit@klimt.1015granger.net>
 <20170616175253.GF12030@fieldses.org>
 <D8C547C0-C361-43F4-8E5C-AF8A6C45C500@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D8C547C0-C361-43F4-8E5C-AF8A6C45C500@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 16, 2017 at 02:37:40PM -0400, Chuck Lever wrote:
> 
> > On Jun 16, 2017, at 1:52 PM, bfields@fieldses.org wrote:
> > 
> > Just repeating some comments from the bug:
> > 
> > On Fri, Jun 16, 2017 at 11:22:54AM -0400, Chuck Lever wrote:
> >> Running a multi-threaded 8KB fio test (70/30 mix), three or four out
> >> of twelve of the jobs fail when using krb5i. The failure is an EIO
> >> on a read.
> >> 
> >> Troubleshooting confirmed the EIO results when the client fails to
> >> verify the MIC of an NFS READ reply. Bruce suggested the problem
> >> could be due to the data payload changing between the time the
> >> reply's MIC was computed on the server and the time the reply was
> >> actually sent.
> >> 
> >> krb5p gets around this problem by disabling RQ_SPLICE_OK.
> > 
> > And you verified that this does fix the problem in your case.
> 
> I've had this applied to my server for a week or so. There
> hasn't been a single recurrence of the issue.
> 
> 
> > So, I think it's a simple fix and probably the best we can do without a
> > lot more work, so I'm happy applying it.
> > 
> > That said, I'm still curious about the performance:
> > 
> >> I would say that there is not much difference in this test.
> > 
> > We added an extra copy to the read path and it didn't seem to affect
> > throughput of streaming read much--I think that just says memory
> > bandwidth isn't the bottlneck in this case?  Which doesn't seem too
> > surprising.
> 
> With krb5i, an additional memory copy is minor compared to the
> computation needed.
> 
> I'm testing with 56Gbps networking and a tmpfs export. I'm not
> exhausting the CPU on my 4-core server, even with krb5p. The
> effects could be seen in a scalability test, but I don't have
> anything that pushes my server that hard.
> 
> 
> > I wonder what we should be looking for--maybe running the same test but
> > also measuring CPU usage somehow.
> 
> Maybe an increase in latency. But I didn't see much change, and
> the throughput numbers don't reflect any underlying increase in
> per-RPC latency.

OK!  Thanks for looking into this.

--b.
