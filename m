Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:32798 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaG3U7D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 16:59:03 -0400
Date: Wed, 30 Jul 2014 13:59:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v3 04/38] nfsd: Replace nfs4_ol_stateid->st_file with the
 st_stid.sc_file
Message-ID: <20140730205902.GB25112@infradead.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-5-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406684083-19736-5-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, I'd merge this into the previous patch.

