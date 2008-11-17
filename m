From: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Mon, 17 Nov 2008 13:35:36 +0100
Message-ID: <20081117123536.GA16539@squirrel.roonstrasse.net>
References: <20081022091207.GA12996@squirrel.roonstrasse.net> <20081023123628.GA18549@squirrel.roonstrasse.net> <1224773745.7625.4.camel@localhost> <20081024083913.GA15197@squirrel.roonstrasse.net> <1224871763.22672.33.camel@localhost> <20081027095843.GA10937@squirrel.roonstrasse.net> <1225122503.14242.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4.netcologne.de ([194.8.194.137]:57954 "EHLO
	smtp4.netcologne.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325AbYKQMfj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 07:35:39 -0500
In-Reply-To: <1225122503.14242.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008/10/27 16:48, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> OK. That points a finger at the garbage collector. Does the following
> patch help at all?

Hi Trond,

the server's load seems to be a little bit lower with 2.6.27.6 plus
your patch, but OProfile still gives me 45% in
rpcauth_lookup_credcache().  See:

1060627  45.1474  (no location information)   rpcauth_lookup_credcache
289362   12.3172  auth_generic.c:0            generic_match
31886     1.3573  page_alloc.c:0              get_page_from_freelist
23932     1.0187  (no location information)   page_fault
22176     0.9440  (no location information)   schedule
14613     0.6220  (no location information)   __d_lookup
[...]

Max
