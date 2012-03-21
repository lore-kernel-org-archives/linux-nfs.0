Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57352 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754305Ab2CUTpq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:45:46 -0400
Date: Wed, 21 Mar 2012 15:45:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: krb5 failures in recent nfs-for-next
Message-ID: <20120321194544.GC11222@fieldses.org>
References: <20120321192448.GB11222@fieldses.org>
 <4F6A2DE8.6060403@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F6A2DE8.6060403@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 21, 2012 at 03:37:12PM -0400, Bryan Schumaker wrote:
> On 03/21/2012 03:24 PM, J. Bruce Fields wrote:
> 
> > Have you been doing any krb5 testing?
> 
> 
> Not yet.  It's still on my Jenkins todo list, but I haven't gotten around to it yet.  Sounds like we need it, though, so I'll try working on it soon.

Actually, I've since seen the failure over nfsv4 and auth_sys.  All
that's left on the console is enough to tell me it's happening in
nfs4_free_lock_state, called from __rpc_execute in a kthread.  (Well,
assuming that's actually the first backtrace.)

--b.
