Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56485 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965142Ab3CZPZI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Mar 2013 11:25:08 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "libtirpc-devel@lists.sourceforge.net"
	<libtirpc-devel@lists.sourceforge.net>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Allow building libtirpc directly against GSSAPI
Date: Tue, 26 Mar 2013 15:25:06 +0000
Message-ID: <1364311505.4534.0.camel@leira.trondhjem.org>
References: <1364308888.2660.119.camel@willson.li.ssimo.org>
In-Reply-To: <1364308888.2660.119.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-03-26 at 10:41 -0400, Simo Sorce wrote:
> Libgssglue is not really useful anymore, it is a sort of middleman that
> wraps the actual GSSAPI that is already pluggable/extensible via shared
> modules.
> 
> In particular libgssglue interferes with the workings of gss-proxy in my
> case.
> 
> The attached patch makes building against libgssglue optional and
> defaults to not build against libgssglue and instead builds directly
> against the native GSSAPI.
> 
> ./configure --enable-gss
> will now build against GSSAPI
> 
> ./configure --enable-gss --with-gssglue
> will keep building against libgssglue in case someone still needs it for
> whatever reason.
> 
> Simo.
> 

Won't that be a backward compatibility issue?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
