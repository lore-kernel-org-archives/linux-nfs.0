From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6
	support is built in
Date: Sun, 1 Feb 2009 12:18:53 -0500
Message-ID: <20090201171853.GA29091@fieldses.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130201041.22301.60941.stgit@ingres.1015granger.net> <1233347546.9741.31.camel@heimdal.trondhjem.org> <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com> <1233350290.9741.42.camel@heimdal.trondhjem.org> <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com> <1233352740.9741.64.camel@heimdal.trondhjem.org> <59D3726F-FB24-4624-891F-55877239B011@oracle.com> <1233355782.9741.95.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:47243 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbZBARSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Feb 2009 12:18:54 -0500
In-Reply-To: <1233355782.9741.95.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 30, 2009 at 05:49:42PM -0500, Trond Myklebust wrote:
> That said, I think I'd prefer the single socket solution that we have
> now. It would certainly make life easier for migration events, and
> possibly pnfs. In neither of these cases do you know at mount time what
> kind of callback service you will need later, so setting up an IPv4-only
> service might turn out wrong.

If I understand right, that's an argument for grabbing both ipv4 and
ipv6 ports as early as possible.

I don't think that's incompatible with using separate sockets for each.
And doing so would simplify adding ipv6 later in situations when it
isn't initially available.  (But such situations might be rare?)

--b.
