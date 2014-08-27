Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f48.google.com ([74.125.82.48]:52285 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbaH0IWo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2014 04:22:44 -0400
Received: by mail-wg0-f48.google.com with SMTP id x13so15507630wgg.19
        for <linux-nfs@vger.kernel.org>; Wed, 27 Aug 2014 01:22:43 -0700 (PDT)
Message-ID: <53FD9550.5010605@gmail.com>
Date: Wed, 27 Aug 2014 11:22:40 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Boaz Harrosh <boaz@plexistor.com>
CC: "Matt W. Benjamin" <matt@linuxbox.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <53FCA183.8000605@plexistor.com>	<1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>	<CAHQdGtT-B7NTP8T7ETgTJD1+84k_KW_5aOfrYjLpA04hoR3YsA@mail.gmail.com>	<53FCBC5A.4060304@plexistor.com>	<CAHQdGtSghgbrPr=X8O2YLq=vXbKY1y5OuOMisf6vRoj8WeF0YA@mail.gmail.com>	<53FCBE9C.40906@plexistor.com>	<CAHQdGtTgcGiWbcZyAsaOzdB=RpdUx17vHcw1yxg7vS56BfwY+A@mail.gmail.com>	<53FCCFBD.3080305@plexistor.com> <CAHQdGtRi_jA8+RkDqh+VBKwHhTpxygSEBWaDScqozyxVSPKAtg@mail.gmail.com>
In-Reply-To: <CAHQdGtRi_jA8+RkDqh+VBKwHhTpxygSEBWaDScqozyxVSPKAtg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 09:41 PM, Trond Myklebust wrote:
<> 
> Whether or not your particular server allows it or not is irrelevant.
> We're not coding the client to a particular implementation. 

God, No this is not up to any particular server implementation
it is stated clearly in the draft text. The Server is specifically
forbidden to wait in lo_get and device_info/device_list actually
any resource that is recallable.

This is the STD exactly for those reasons you stated.

> None of
> the other callbacks do synchronous RPC calls, and that's very
> intentional.
> 

Because none of the other callbacks have the protection of the STD
that forbids the server of synchronous operations, so the client
have to.

Thanks
Boaz

