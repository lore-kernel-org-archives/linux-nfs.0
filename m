From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Tue, 05 Feb 2008 12:50:39 -0500
Message-ID: <1202233839.8452.31.camel@heimdal.trondhjem.org>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net>
	 <47A7AB89.7020709@melbourne.sgi.com>
	 <1202170754.28484.57.camel@heimdal.trondhjem.org>
	 <47A7AE03.10401@melbourne.sgi.com>
	 <4BE5A1AE-DB3B-4796-B6BD-5691930258C8@oracle.com>
	 <47A7F8F3.3020907@melbourne.sgi.com>  <20080205155021.GA7805@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	Chuck Lever <chuck.lever@oracle.com>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:41493 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754789AbYBERuw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 12:50:52 -0500
In-Reply-To: <20080205155021.GA7805@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-02-05 at 16:50 +0100, Frank van Maarseveen wrote:
> Last time I checked (around 2.6.22) writing large files on NFSv3 over
> UDP was 20% faster compared to TCP (Gb LAN with one switch connecting
> all machines).
> 
> TCP and its timeout/retransmission behavior isn't always the best choice.

If your environment has only 1 client working against a dedicated NFS
server on a clean network, then that may indeed be the case, but as soon
as you have more than 1 client, TCP almost always ends up outperforming
UDP.

Cheers
  Trond

