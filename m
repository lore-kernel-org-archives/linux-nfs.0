From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Tue, 5 Feb 2008 18:08:28 -0500
Message-ID: <20080205230828.GV8210@fieldses.org>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net> <47A7AB89.7020709@melbourne.sgi.com> <1202170754.28484.57.camel@heimdal.trondhjem.org> <47A7AE03.10401@melbourne.sgi.com> <4BE5A1AE-DB3B-4796-B6BD-5691930258C8@oracle.com> <47A7F8F3.3020907@melbourne.sgi.com> <20080205155021.GA7805@janus> <47A8EBC3.7050900@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:34961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbYBEXIu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 18:08:50 -0500
In-Reply-To: <47A8EBC3.7050900-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 10:05:39AM +1100, Greg Banks wrote:
> Frank van Maarseveen wrote:
> > Last time I checked (around 2.6.22) writing large files on NFSv3 over
> > UDP was 20% faster compared to TCP (Gb LAN with one switch connecting
> > all machines).
> >   
> Did all of your file arrive at the server, and in the same order it left
> the client?  NFS on UDP relies on IP fragmentation, which is known to
> introduce silent data corruption at high data rates (google for "IPID aliasing").

The right query appears to be "IPID aliasing NFS", which (at least for
me) gets you a nice explanation from Olaf's 2006 OLS paper as the first
hit....

--b.

> Also, last time I checked, UDP support in the server uses a single socket
> for all traffic, and processes need to serialise on the svc_sock lock to send,
> so aggregate UDP throughput is strictly limited compared to TCP.  As in, 145 MB/s
> for UDP compared to filling 12 1gige pipes for TCP.  I have a patch to fix this,
> but given the inherent data corruption issues of UDP I haven't bothered posting
> the most recent version.
> 
> 
> 
> > TCP and its timeout/retransmission behavior isn't always the best choice.
> >
> >   
> The timeout & retrans that sunrpc implements on top of UDP is arguably worse,
> especially if you use the "soft" mount option.
> 
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> The cake is *not* a lie.
> I don't speak for SGI.
> 
