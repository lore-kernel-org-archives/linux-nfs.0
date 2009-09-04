From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mount.nfs oops [was: mmotm 2009-09-03-16-35 uploaded]
Date: Fri, 04 Sep 2009 18:53:17 -0400
Message-ID: <1252104797.5274.19.camel@heimdal.trondhjem.org>
References: <200909032340.n83Ne6E6004708@imap1.linux-foundation.org>
	 <4AA17E74.8060100@gmail.com>
	 <1252102337.5274.4.camel@heimdal.trondhjem.org>
	 <4AA19420.5060503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51257 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934427AbZIDWxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 18:53:42 -0400
In-Reply-To: <4AA19420.5060503@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-09-05 at 00:26 +0200, Jiri Slaby wrote:
> On 09/05/2009 12:12 AM, Trond Myklebust wrote:
> > Also, were you doing anything special at the time (for instance removing
> > a module)?
> 
> Not at all. I just did
> # mount /work
> # grep work /etc/fstab
> XXX.YYY.ZZZ:/work     /work           nfs     defaults,intr   0 0
> 
> Thanks.

Hmm... Is it fully reproducible? I'm running the same NFS client code
(although not the full linux-mm) on several different client platforms
without seeing any issues.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
