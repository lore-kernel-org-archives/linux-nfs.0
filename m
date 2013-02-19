Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:23175 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869Ab3BSEpP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 23:45:15 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH v3 1/9] SUNRPC: Missing module alias for auth_rpcgss.ko
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235CF1F8@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 18 Feb 2013 23:45:11 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <A9639E03-2719-41BD-98D4-D30732EF022A@oracle.com>
References: <20130204201458.1518.12931.stgit@seurat.1015granger.net> <20130204201903.1518.91133.stgit@seurat.1015granger.net> <4FA345DA4F4AE44899BD2B03EEEC2FA9235CF1F8@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2013, at 1:42 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-02-04 at 15:19 -0500, Chuck Lever wrote:
>> Commit f344f6df "SUNRPC: Auto-load RPC authentication kernel
>> modules", Mon Mar 20 13:44:08 2006, adds a request_module() call
>> in rpcauth_create() to auto-load RPC security modules when a ULP
>> tries to create a credential of that flavor.
>> 
>> In rpcauth_create(), the name of the module to load is built like
>> this:
>> 
>> 	request_module("rpc-auth-%u", flavor);
>> 
>> This means that for, say, RPC_AUTH_GSS, request_module() is looking
>> for a module or alias called "rpc-auth-6".
>> 
>> The GSS module is named "auth_rpcgss", and commit f344f6df does not
>> add any new module aliases.  There is also no such alias provided in
>> /etc/modprobe.d on my system (Fedora 16).  Without this alias, the
>> GSS module is not loaded on demand.
> 
> Wait... Why do we want to load the auth_rpcgss module on its own? It
> doesn't provide any authentication or security mechanisms of its own.
> All it does is to provide support for the other security mechanisms.

This is a bootstrap.  Have a look at the logic in rpcauth_create().

Suppose auth_rpcgss.ko has not been loaded, and some caller wants to create an rpc_auth with pseudoflavor RPC_AUTH_GSS_KRB5.

pseudoflavor_to_flavor() converts RPC_AUTH_GSS_KRB5 to RPC_AUTH_GSS.  RPC_AUTH_GSS is used to index the auth_flavors[] array, where the ops pointer is found to be NULL.  In that case request_module() is invoked with the argument "rpc-auth-6".

Without the module alias, nothing happens: at line 194, the ops pointer at index "flavor" is still NULL, and rpcauth_create() exits with -EINVAL.

With the module alias, authrpc_gss.ko is loaded.  This makes ops->create() for GSS available, which is then invoked with the argument RPC_AUTH_GSS_KRB5.  authrpc_gss.ko in turn loads rpcsec_gss_krb5.ko, and the bootstrap is complete.

All of this logic has been in here since Olaf added it, but has lain fallow without the "rpc-auth-6" module alias.  We've not hit a problem before, I believe, because distributions have worked around the missing modules by loading them via init scripts.


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




