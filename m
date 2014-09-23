Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:38036 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbaIWVag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 17:30:36 -0400
Date: Tue, 23 Sep 2014 14:30:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: [PATCH 1/4] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-Id: <20140923143034.4adbbbfd12174baaab1a1ee4@linux-foundation.org>
In-Reply-To: <20140923121052.55dcb4f5@notabene.brown>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053134.22257.28841.stgit@notabene.brown>
	<20140918144222.GP2840@worktop.localdomain>
	<20140923121052.55dcb4f5@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Sep 2014 12:10:52 +1000 NeilBrown <neilb@suse.de> wrote:

> Now I just need an Ack from akpm for the mm bits (please...)

Ack
