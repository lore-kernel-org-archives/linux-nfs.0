From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: Union mounts, NFS, and locking
Date: Thu, 16 Jul 2009 17:22:28 -0400
Message-ID: <1247779348.2516.136.camel@localhost>
References: <20090714201940.GF27582@shell>
	 <200907142036.n6EKaexe017464@agora.fsl.cs.sunysb.edu>
	 <20090714220515.GH27582@shell>  <20090715172758.GA13893@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Valerie Aurora <vaurora@redhat.com>,
	Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea01.nsa.gov ([63.239.67.1]:43144 "EHLO
	msux-gh1-uea01.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933391AbZGPWO5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2009 18:14:57 -0400
In-Reply-To: <20090715172758.GA13893@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-07-15 at 13:27 -0400, J. Bruce Fields wrote:
[snip]
> The mount options aren't really in the protocol--so it'd probably take
> the form of a filesystem-granularity attribute that the client could
> query (and then fail the mount if the client didn't like the answer).
> 
> But even then: the fact is that someone will want to update the
> filesystem some day.  And there's no way to force every client
> administrator to remount.  So we'd have to decide how to handle that
> case.

So currently this is the case but at the last IETF meeting I proposed a
remount callback to handle the case of a mass file relabel on the
server. I think Beepy wrote it down on the possible 4.2 items. However I
wouldn't expect to see anything related to that for a while and that
assumes that someone picks up the ball and runs with it to begin with. 

Dave

P.S. Note this is NFSv4 we are talking about I don't have a solution for
v2(does anyone even use it any more?) or v3

