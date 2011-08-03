Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:51401 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948Ab1HCLxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 07:53:04 -0400
Date: Wed, 3 Aug 2011 07:53:02 -0400
From: Jim Rees <rees@umich.edu>
To: Peng Tao <bergwolf@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110803115302.GB5453@merit.edu>
References: <1312233006.23392.17.camel@lade.trondhjem.org>
 <1312238117.23392.19.camel@lade.trondhjem.org>
 <20110802022144.GA18157@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com>
 <20110802032320.GA18296@merit.edu>
 <1312288134.4616.21.camel@lade.trondhjem.org>
 <20110803014808.GA4692@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778AE2@SACMVEXC2-PRD.hq.netapp.com>
 <20110803023805.GA4863@merit.edu>
 <CA+a=Yy6ajY+Te6ij3KTM0sNSf-jjFVubReqWLJ5UnN8cuhdidQ@mail.gmail.com>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <CA+a=Yy6ajY+Te6ij3KTM0sNSf-jjFVubReqWLJ5UnN8cuhdidQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peng Tao wrote:

  On Wed, Aug 3, 2011 at 10:38 AM, Jim Rees <rees@umich.edu> wrote:
  > Myklebust, Trond wrote:
  >
  >  Can you try to turn on the callback debugging ('echo 256 >
  >  /proc/sys/sunrpc/nfs_debug')? A wireshark trace of what is going on
  >  during the hang itself might also help.
  >
  > It doesn't fail with callback debugging turned on.  I suspect the output to
  > my slow serial console disrupts the timing.
  >
  > The trace is in
  > http://www.citi.umich.edu/projects/nfsv4/pnfs/block/download/089.pcap
  In frame 8785, client returned NFS4ERR_DELAY in response to
  CB_SEQUENCE and the next RPC was 12s later. So it should be the case
  that Trond mentioned above.

That trace was taken with Trond's two patches applied.  So they did not fix
the problem for me.
