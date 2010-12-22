Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:34345 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713Ab0LVXyv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Dec 2010 18:54:51 -0500
Date: Wed, 22 Dec 2010 18:54:48 -0500
From: Jim Rees <rees@umich.edu>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] NFS: call_sync function
Message-ID: <20101222235447.GA25778@merit.edu>
References: <4D1272B6.9000907@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D1272B6.9000907@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bryan Schumaker wrote:

  This patch changes nfs4_call_sync() from a macro into a
  static inline function.

Makes sense, but why change the arguments?
