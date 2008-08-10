From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [2.6 patch] uninline nfsd4_op_name()
Date: Sun, 10 Aug 2008 14:32:31 +0300
Message-ID: <489ED1CF.8000308@panasas.com>
References: <20080808162642.GG14495@cs181140183.pp.htv.fi> <alpine.LFD.1.10.0808081120570.3462@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Adrian Bunk <bunk@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:28521 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754209AbYHJLdR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Aug 2008 07:33:17 -0400
In-Reply-To: <alpine.LFD.1.10.0808081120570.3462-nfNrOhbfy2R17+2ddN/4kux8cNe9sq/dYPYVAmT7z5s@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus Torvalds wrote:
> 
> On Fri, 8 Aug 2008, Adrian Bunk wrote:
>> There doesn't seem to be a compelling reason why nfsd4_op_name() is 
>> marked as "inline":

Agreed.

> 
> It should also return a "const char *", I think.
> 
> Since it does.

Right.

> 
> 		Linus

Thanks for picking this up,

Benny
