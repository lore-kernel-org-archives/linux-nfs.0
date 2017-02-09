Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49506 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752848AbdBIOZF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 09:25:05 -0500
Date: Thu, 9 Feb 2017 06:25:04 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Frank Sorenson <sorenson@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] Replace non-thread-safe strtok function calls
 in gssd
Message-ID: <20170209142504.GA26900@infradead.org>
References: <6481e076-509a-1b60-bc46-7ac537ca24fe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6481e076-509a-1b60-bc46-7ac537ca24fe@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

strtok_k is just as horrible as strtok, if you want to use a proper
API switch to strsep()
