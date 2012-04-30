Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:33471 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264Ab2D3SO1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 14:14:27 -0400
Received: by vbbff1 with SMTP id ff1so2251022vbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 11:14:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335809108.11828.1.camel@lade.trondhjem.org>
References: <1335808841-11623-1-git-send-email-Trond.Myklebust@netapp.com>
	<1335808841-11623-2-git-send-email-Trond.Myklebust@netapp.com>
	<1335809108.11828.1.camel@lade.trondhjem.org>
Date: Mon, 30 Apr 2012 14:14:26 -0400
Message-ID: <CADnza47oEXNJOap9wv=3aT_gQGYJ9GSHbyBpDJy7qROhQ7aBZA@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFS: O_DIRECT pgio_completion_ops error_cleanup must
 unlock the request
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 30, 2012 at 2:05 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> Alternatively, we could probably just send the write requests in an
> unlocked state. They aren't supposed to be visible to anything via any
> global lists...
>


The existing lock/commit code fairly often assumes the reqs are
locked.  I found it simpler to just lock the req than to audit all the
code paths looking for where the assumptions made a difference.

Fred
