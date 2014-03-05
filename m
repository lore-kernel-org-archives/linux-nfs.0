Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33945 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaCEOnG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 09:43:06 -0500
Received: by mail-ig0-f170.google.com with SMTP id uq10so7807704igb.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 06:43:06 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 4/8] sunrpc/auth: add 'rcu_walk' arg to rpc_lookup_cred.
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140305030028.27421.14840.stgit@notabene.brown>
Date: Wed, 5 Mar 2014 09:43:03 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <B5AA3471-423B-436C-B3A1-4579917913F6@primarydata.com>
References: <20140305025813.27421.23871.stgit@notabene.brown> <20140305030028.27421.14840.stgit@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 4, 2014, at 22:00, NeilBrown <neilb@suse.de> wrote:

> This arg causes rpc_lookup_cred to set RPCAUTH_LOOKUP_RCU when
> performing the credential lookup.  Most callers pass '0',
> except nfs_permission() which passes (mask & MAY_NOT_BLOCK).
> 

Why not just add a function rpc_lookup_cred_rcu() or rpc_lookup_cred_noblock() to cater for that one exception?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

