Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:47118 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756021AbcCUOnv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 10:43:51 -0400
Date: Mon, 21 Mar 2016 15:43:49 +0100
From: Christoph Hellwig <hch@lst.de>
To: Nelson Elhage <nelhage@nelhage.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Bruce Fields <bfields@fieldses.org>, James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
Message-ID: <20160321144349.GA12804@lst.de>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Nelson,

this was indeed most likely caused by my patch.  Just to narrow things
down can your clarify that the scenarious is that you have CONFIG_NFS_V3
set on your client, you're talking to a server not supporting ACLs
at all, and a tool trying to set an ACL is getting the wrong return
value?  If so I should be able to reproduce this locally.
