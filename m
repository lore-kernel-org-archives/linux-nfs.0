Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37437 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076Ab1HCOLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 10:11:39 -0400
Date: Wed, 3 Aug 2011 10:11:37 -0400
From: Jim Rees <rees@umich.edu>
To: Peng Tao <bergwolf@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110803141137.GA6782@merit.edu>
References: <20110802022144.GA18157@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com>
 <20110802032320.GA18296@merit.edu>
 <1312288134.4616.21.camel@lade.trondhjem.org>
 <20110803014808.GA4692@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778AE2@SACMVEXC2-PRD.hq.netapp.com>
 <20110803023805.GA4863@merit.edu>
 <CA+a=Yy6ajY+Te6ij3KTM0sNSf-jjFVubReqWLJ5UnN8cuhdidQ@mail.gmail.com>
 <20110803115302.GB5453@merit.edu>
 <CA+a=Yy5iLO5R=U6Z0KbBKEx608Zw_rvQ8RJaT4fqBpW02f__nQ@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+a=Yy5iLO5R=U6Z0KbBKEx608Zw_rvQ8RJaT4fqBpW02f__nQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peng Tao wrote:

  How do you reproduce it? I was reproducing it by running ./check -nfs
  and let it run to case 089 and kill it after case 089 run for seconds.

./check -nfs 089

After less than a minute, I start getting hung tasks (I have hung task
timeout set to 10 sec).
