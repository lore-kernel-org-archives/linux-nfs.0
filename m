Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:45873
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693Ab1G2Pvm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 11:51:42 -0400
Date: Fri, 29 Jul 2011 11:51:36 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110729155136.GB28306@infradead.org>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311874276-1386-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

How well is the I/O code tested?  It's a full reimplementation of
code full of nasty traps.  Did you run xfstests over it?  It supports
nfs, so pointing it to a pnfs share should probably just work.

