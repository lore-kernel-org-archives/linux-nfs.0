Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:60198 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932221AbcKBRMC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Nov 2016 13:12:02 -0400
Date: Wed, 2 Nov 2016 18:11:49 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>
Subject: Re: [PATCH v3] NFSv4: replace seqcount_t with a rw_semaphore
Message-ID: <20161102171149.kl66dlmlrc44zock@linutronix.de>
References: <20161021164727.24485-1-bigeasy@linutronix.de>
 <20161028210511.k7hrsfxovti7gqtu@linutronix.de>
 <747E2CCB-3D83-40FD-8B31-46AB5A5E8592@primarydata.com>
 <20161031131958.mrrez5t7sow75p6v@linutronix.de>
 <51E3F753-2D1F-4370-BFEB-BD8356D622A1@primarydata.com>
 <20161031155616.fqbqy53bwpanufhn@linutronix.de>
 <40147FA4-9FD8-4349-B309-751DFCE875A2@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <40147FA4-9FD8-4349-B309-751DFCE875A2@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016-10-31 16:11:02 [+0000], Trond Myklebust wrote:
> 
> Yes, and yes. We can’t rely on the list pointers remaining correct, so we restart the list scan and we use the ops->state_flag_bit to signal whether or not state has been recovered for the entry being scanned.

but this is tested at the top of the loop and by then you look at
lists' ->next pointer which might be invalid.

Sebastian
