Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53839 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933158AbcE3QDm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 May 2016 12:03:42 -0400
Date: Mon, 30 May 2016 09:03:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anne Marie Merritt <anne.marie.merritt@gmail.com>
Cc: trondmy@primarydata.com, linux-nfs@vger.kernel.org,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: Re: [PATCH 0/6] nfs:  add support for additional attributes and
 ioctl to access
Message-ID: <20160530160340.GA8137@infradead.org>
References: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anne,

we really should not any of these as a special hacks specific to a file
system.  Take a look at thread on xstat on linux-fsdevel for a more
general solution.
