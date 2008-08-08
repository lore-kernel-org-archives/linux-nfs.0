From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [2.6 patch] uninline nfsd4_op_name()
Date: Fri, 8 Aug 2008 11:25:35 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808081120570.3462@nehalem.linux-foundation.org>
References: <20080808162642.GG14495@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53917 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752002AbYHHS01 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2008 14:26:27 -0400
In-Reply-To: <20080808162642.GG14495-re2QNgSbS3j4D6uPqz5PAwR5/fbUUdgG@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Fri, 8 Aug 2008, Adrian Bunk wrote:
>
> There doesn't seem to be a compelling reason why nfsd4_op_name() is 
> marked as "inline":

It should also return a "const char *", I think.

Since it does.

		Linus
