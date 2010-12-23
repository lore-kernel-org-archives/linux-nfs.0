Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30991 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab0LWAOb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Dec 2010 19:14:31 -0500
Subject: Re: [PATCH 1/5] NFS: call_sync function
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20101222235447.GA25778@merit.edu>
References: <4D1272B6.9000907@netapp.com> <20101222235447.GA25778@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 22 Dec 2010 19:14:27 -0500
Message-ID: <1293063267.6422.53.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-22 at 18:54 -0500, Jim Rees wrote:
> Bryan Schumaker wrote:
> 
>   This patch changes nfs4_call_sync() from a macro into a
>   static inline function.
> 
> Makes sense, but why change the arguments?

Not sure I understand. Do you mean the change from untyped args and res
to nfs4_sequence_args and nfs4_sequence_res? That would be to enable
proper type checking.

That part of the macro was always a dirty hack which relied on the
sequence related arguments always having the same names, and which only
served to avoid having to type those 8 characters per argument...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

