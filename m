Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28701 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964812AbbEVOZI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 May 2015 10:25:08 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: New libtirpc vs fedfs-utils.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150522135442.048de45d@notabene.brown>
Date: Fri, 22 May 2015 10:25:20 -0400
Cc: Steve Dickson <SteveD@redhat.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Thorsten Kukuk <kukuk@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A2BEDA4A-5064-4715-A49B-ABA7247BF7DB@oracle.com>
References: <20150522135442.048de45d@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-


On May 21, 2015, at 11:54 PM, NeilBrown <neilb@suse.de> wrote:

> 
> 
> Hi Chuck / Steve,
> 
> It seems that fedfs-utils doesn't build with the new libtirpc.
> 
> Specifically fedfsd requires symbols
> 
>  svcauth_gss_set_svc_name
>  svcauth_gss_get_principal
> 
> but libtirpc doesn't expose them any longer - it never included them in .h
> files or provided documentation.
> 
> As far as I can tell fedfs-utils really does need these interfaces, there is
> no alternate.

fedfs-utils needs to be updated, now that the new rpc_gss API is merged
into libtirpc, to use rpc_gss_set_svc_name(3t) and rpc_gss_getcred(3t).
That’s on my to-do list.

In the meantime . . .

> Would it be appropriate to make them "official" with header and doco support?

A fix for this issue was proposed yesterday on libtirpc-devel.


> A simple hack is:
> 
> --- libtirpc-0.3.0.orig/src/libtirpc.map
> +++ libtirpc-0.3.0/src/libtirpc.map
> @@ -284,4 +284,6 @@ TIRPC_PRIVATE {
>     __libc_clntudp_bufcreate;
>   # private, but used by rpcbind:
>     __svc_clean_idle; svc_auth_none; libtirpc_set_debug;
> +  # private, but used by fedfsd:
> +   svcauth_gss_set_svc_name; svcauth_gss_get_principal;
> };
> 
> 
> but I suspect something better is really needed.
> 
> Are there other server-side routines that need to be exported?
> 
> Thanks,
> NeilBrown

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



