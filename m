From: Jim Rees <rees@umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Date: Tue, 2 Aug 2011 22:11:12 -0400
Message-ID: <20110803021112.GA4819@merit.edu>
References: <20110730032621.GB25188@merit.edu>
 <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
 <1312233006.23392.17.camel@lade.trondhjem.org>
 <1312238117.23392.19.camel@lade.trondhjem.org>
 <20110802022144.GA18157@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com>
 <20110802032320.GA18296@merit.edu>
 <1312288134.4616.21.camel@lade.trondhjem.org>
 <20110803014808.GA4692@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778AE2@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peng Tao <bergwolf@gmail.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:56379 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab1HCCLO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2011 22:11:14 -0400
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778AE2-hX7t0kiaRRrlMGe9HJ1VYQK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  Can you try to turn on the callback debugging ('echo 256 >
  /proc/sys/sunrpc/nfs_debug')? A wireshark trace of what is going on
  during the hang itself might also help.

Will do, tomorrow morning.
