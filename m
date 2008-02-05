From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Tue, 5 Feb 2008 19:08:19 +0100
Message-ID: <20080205180819.GA12916@janus>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net> <47A7AB89.7020709@melbourne.sgi.com> <1202170754.28484.57.camel@heimdal.trondhjem.org> <47A7AE03.10401@melbourne.sgi.com> <4BE5A1AE-DB3B-4796-B6BD-5691930258C8@oracle.com> <47A7F8F3.3020907@melbourne.sgi.com> <20080205155021.GA7805@janus> <1202233839.8452.31.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	Chuck Lever <chuck.lever@oracle.com>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:36652 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758408AbYBESIU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 13:08:20 -0500
In-Reply-To: <1202233839.8452.31.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 05, 2008 at 12:50:39PM -0500, Trond Myklebust wrote:
> 
> On Tue, 2008-02-05 at 16:50 +0100, Frank van Maarseveen wrote:
> > Last time I checked (around 2.6.22) writing large files on NFSv3 over
> > UDP was 20% faster compared to TCP (Gb LAN with one switch connecting
> > all machines).
> > 
> > TCP and its timeout/retransmission behavior isn't always the best choice.
> 
> If your environment has only 1 client working against a dedicated NFS
> server on a clean network, then that may indeed be the case, but as soon
> as you have more than 1 client, TCP almost always ends up outperforming
> UDP.

There are multiple clients (12 per physical server on average) but the
clients generally don't write (or read) at the same time. Anyway, I'll
keep this in mind.

-- 
Frank
