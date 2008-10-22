From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Wed, 22 Oct 2008 13:56:17 -0400
Message-ID: <20081022175617.GA2495@fieldses.org>
References: <20081022091207.GA12996@squirrel.roonstrasse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33159 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657AbYJVR4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 13:56:19 -0400
In-Reply-To: <20081022091207.GA12996-2pNSKKP3PSJxEiad3KpGLI/oZP4lHnOC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2008 at 11:12:08AM +0200, Max Kellermann wrote:
> Hi,
> 
> after I was able to fix http://lkml.org/lkml/2008/10/17/147, the
> server which was already upgraded to 2.6.27.2 still gets very high
> load.  It is a web server with NFS file storage (NetApp), and while
> the others in the cluster (kernel 2.6.25) have a load of 1-3, 2.6.27.2
> gets 30-50.
> 
> I did an oprofile, with the following results (server just started,
> load "only" 5-10):

Well, there's only 7 patches to net/sunrpc/auth.c between 2.6.25 and
today, so worst case a 'git bisect v2.6.25..v2.6.27 net/sunrpc/auth.c'
might not be too bad.

No particular idea why rpcauth_lookup_credcache would be a problem,
though.

--b.

> 
> 87593    56.1116  (no location information)   vmlinux
> vmlinux                  rpcauth_lookup_credcache
> 16037    10.2732  auth_generic.c:0            vmlinux
> vmlinux                  generic_match
> 6460      4.1382  (no location information)   php4
> php4                     (no symbols)
> 2478      1.5874  (no location information)   libc-2.7.so
> libc-2.7.so              (no symbols)
> [...]
> 
> We havn't configured any special authentication method.  It is a NFSv3
> over UDP mount, but the kernel has NFSv4 and therefore KRB5 enabled.
> 
> Any ideas why rpcauth_lookup_credcache() goes overboard with CPU
> usage?
> 
> Max
