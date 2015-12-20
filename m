Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47800 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbbLTPpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Dec 2015 10:45:09 -0500
Date: Sun, 20 Dec 2015 07:45:07 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v2 1/3] NFSD: Don't pass filehandle to
 nfs4_preprocess_stateid_op()
Message-ID: <20151220154507.GA18236@infradead.org>
References: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1450472727-19893-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1450472727-19893-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 18, 2015 at 04:05:24PM -0500, Anna Schumaker wrote:
> This reverts commit 3679e4c1ef1c00ea30d15b9ae59089b44dfe4137.
> 
> We either pass the current_fh or save_fh from the cstate structure, and
> not some generic filehandle.  Let's just add a flag to pick between these
> two filehandles instead.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

I don't really find this much cleaner to be honest.

>  fs/nfs/objlayout/Makefile |  0

how did this end up in the diffstat, btw?
