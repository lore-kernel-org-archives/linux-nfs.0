From: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Fri, 24 Oct 2008 10:39:13 +0200
Message-ID: <20081024083913.GA15197@squirrel.roonstrasse.net>
References: <20081022091207.GA12996@squirrel.roonstrasse.net> <20081023123628.GA18549@squirrel.roonstrasse.net> <1224773745.7625.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4.netcologne.de ([194.8.194.137]:43602 "EHLO
	smtp4.netcologne.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbYJXIjP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 04:39:15 -0400
In-Reply-To: <1224773745.7625.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008/10/23 16:55, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> Can you add a '-v' to the rpc.gssd daemon startup line? I'd like to see
> how often you are creating new gss contexts.

There is no rpc.gssd running on any of these servers, we're using
plain NFSv3 without (protocol based) authentication.  Do you want me
to start it anyway?

Max
