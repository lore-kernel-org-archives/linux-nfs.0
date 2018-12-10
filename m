Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAA54C5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 18:12:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE6A720672
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 18:12:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE6A720672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727952AbeLJSMk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 13:12:40 -0500
Received: from mail-yb1-f179.google.com ([209.85.219.179]:41538 "EHLO
        mail-yb1-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727422AbeLJSMk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 13:12:40 -0500
Received: by mail-yb1-f179.google.com with SMTP id e124so3135552ybb.8
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2018 10:12:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=0GipCXjrTJvHxLQfM0P60aby/pBmeUvOK0BRvqTJpK0=;
        b=MCb9KeK75NtsbATejdSD6Fc9P0/Ij1bBftbM3dFE578Ze350VwQcXGXHj67z0vZEMe
         M2P1k88VYLqbE+poAeb+GRo2lNkh6DvtpgQ8SQszWajadkwsdBsgZTf6fMuRlGaNJHvZ
         Cns8ZLZbtKaa9sC7j7Mf7vbTcxcFyOkp/aJRMC9O9bwsxkGUeEJdgh9FDkLD1n85Lxlq
         dhWYUEQkZD+61qsZjQ0qCiYjlzPqbdgBmsKNTGfbHOxq0QBybZcfXpGSjr91upEs9jrK
         fs9Q+njbOuh+/wVM1/y6VwCByprAdXfMxsqUIepWH32mtn6XHOEMRG9zi8DietkGMPz4
         7YOQ==
X-Gm-Message-State: AA+aEWYMEXQMvNg5Tg7KNQwzo7nozcSE+PC9rGkc/YRgPIM4NjK2VXwJ
        SmVoiMMYhXIObBl3wdla2c0elw==
X-Google-Smtp-Source: AFSGD/WB0t5+90vEK6fzNtu/rGpFbQt8xPsOqm76WiPXJBt25DlD0scHAAZCTuCVZ4Fy9yHwpBDj8Q==
X-Received: by 2002:a25:d848:: with SMTP id p69mr11655110ybg.378.1544465558690;
        Mon, 10 Dec 2018 10:12:38 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-E54.dyn6.twc.com. [2606:a000:1100:db::e54])
        by smtp.gmail.com with ESMTPSA id v191sm3967106ywc.102.2018.12.10.10.12.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Dec 2018 10:12:38 -0800 (PST)
Message-ID: <0ff22d33d5d7d2b3fad241ebb2aa0e5c5cb70396.camel@redhat.com>
Subject: Re: listing knfsd-held locks and opens
From:   Jeff Layton <jlayton@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date:   Mon, 10 Dec 2018 13:12:31 -0500
In-Reply-To: <20181210174720.GA2925@fieldses.org>
References: <20181210174720.GA2925@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.2 (3.30.2-2.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-12-10 at 12:47 -0500, J. Bruce Fields wrote:
> We've got a long-standing complaint that tools like lsof, when run on an
> NFS server, overlook opens and locks held by NFS clients.
> 
> The information's all there, it's just a question of how to expose it.
> 
> Easiest might be a single flat file like /proc/locks, but I've always
> hoped we could do something slightly more structured, using a
> subdirectory per NFS client.
> 
> Jeff Layton looked into this several years ago.  I don't remember if
> there was some particular issue or if he just got bogged down in VFS
> details.
> 

I think I had a patch that generated a single flat file for locks, but
you wanted to present a directory or file per-client, and I just never
got around to reworking the earlier patch.

> My concerns are that:
> 
> 	- I'd like the format to be easily expandable.  The option to
> 	  create new files seems like it would help.

Yes. We do need to bear in mind that someone will eventually write
scripts to scrape this info. We may want to consider this a formal part
of kernel ABI from the get-go and tread carefully when making changes
after the initial merge.

> 	- some of the data we'd like to expose may be kind of cumbersome
> 	  include as a column in a text file.  (I'm thinking of the
> 	  NFSv4 client identifier, which the protocol allows to be up to
> 	  1K of binary data, even if most (all?) clients use shorter
> 	  ascii identifiers.)
> 
> I'm not sure I'd want to go as far as a sysfs-like one-value-per-file
> rule, which seems like overkill?
> 
> In a little more detail, as starting point, I was considering naming
> each client directory with a small integer, and including files like:
> 
> 	info: a text file with
> 		NFS protocol version
> 		ascii representation of client address
> 		krb5 principal if available
> 
> 	clientid: NFSv4 client ID; file absent for NFSv2/3 clients.
> 
> 	locks: list of locks, following something like the /proc/locks
> 		format.
> 
> 	opens: list of file opens, with access bits, inode numbers,
> 		device number.
> 
> Does that sound reasonable?  Any other ideas?
> 

That sounds like a great start. Some ideas:

The locks file could also list delegations and layouts, but it might be
good to do them in separate files. That would make it cleaner to display
info that is only relevant to those types (recall info, in particular).

You might also consider adding a v4-specific info file. Show things like
"when was last lease renewal"?
-- 
Jeff Layton <jlayton@redhat.com>

