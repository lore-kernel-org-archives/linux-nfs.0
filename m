Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:33448 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbaGJMUp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:20:45 -0400
Received: by mail-qg0-f54.google.com with SMTP id q107so7359785qgd.41
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 05:20:44 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 08:20:43 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 016/100] nfsd: always hold the fi_lock when bumping
 fi_access refcounts
Message-ID: <20140710082043.25418f69@tlielax.poochiereds.net>
In-Reply-To: <20140710085107.GA20292@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-17-git-send-email-jlayton@primarydata.com>
	<20140710085107.GA20292@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 01:51:07 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Any reason to keep the access counts atomic with this?
> 

Yes. We don't have to hold the lock when putting refcounts if we do.

-- 
Jeff Layton <jlayton@primarydata.com>
