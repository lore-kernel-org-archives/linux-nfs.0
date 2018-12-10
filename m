Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D456C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 23:35:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 61A852081F
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 23:35:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61A852081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728182AbeLJXfF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 18:35:05 -0500
Received: from mail-qk1-f182.google.com ([209.85.222.182]:44083 "EHLO
        mail-qk1-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726693AbeLJXfF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 18:35:05 -0500
Received: by mail-qk1-f182.google.com with SMTP id n12so7567647qkh.11
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2018 15:35:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=nyHGiarUiZadwO4Zu3vi9MZV2Sk130ltMG/1hZ/TjMU=;
        b=aqNBjF31N3ggM0JhbrCh2S0jNsSVmekFpTJeeCEyJXJd8MAFi0Lk33sI+aKsQX5c8j
         j9kPD2PYBTqsz7B93Hw+hIyOPQxzYp93lKHTToNu2AuHn6YIbQLW5AZl5PTGXedvuiT1
         M1R+UTNzYItRSgrk0YwX1YVDE799dl/NkMB8NUQqEXjXJE3kX1fzLsB/z64W9Pb1qw4V
         1xwchsBd1dBYK3TJvgz6VrL1CnPv8SNt7+ZBUdT3M5NmYLVM3CFbbUrFQfw4tJQxPM93
         wBZcZxUgQU/BQ6pm2oDW9jxP8FELbY442BQE6OcAlemqlPeKeA+Hoy+eSS1SOy749qP5
         Yjww==
X-Gm-Message-State: AA+aEWbO9ab4ilUxHUaWsxyj4uAbfv5fr3I/5dKZDHl2Krx+0fhb69ED
        /LUZMN5hpPdkAU4syvB8Ue0O1EtvMh4=
X-Google-Smtp-Source: AFSGD/XceQj6z0MTdx/0KrZQUUZDcBXuLvMlSsY8eBIF6yZK1fqzzoZ1FDP6nBo8XOwxb8OGveF6DA==
X-Received: by 2002:a37:7183:: with SMTP id m125mr12245296qkc.195.1544484904077;
        Mon, 10 Dec 2018 15:35:04 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-E54.dyn6.twc.com. [2606:a000:1100:db::e54])
        by smtp.gmail.com with ESMTPSA id w22sm8057701qtw.71.2018.12.10.15.35.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Dec 2018 15:35:03 -0800 (PST)
Message-ID: <ff22a1181606615ae9eb686f39ee5eded341c35b.camel@redhat.com>
Subject: Re: listing knfsd-held locks and opens
From:   Jeff Layton <jlayton@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date:   Mon, 10 Dec 2018 18:35:02 -0500
In-Reply-To: <20181210195347.GA4392@fieldses.org>
References: <20181210174720.GA2925@fieldses.org>
         <0ff22d33d5d7d2b3fad241ebb2aa0e5c5cb70396.camel@redhat.com>
         <20181210192310.GC2925@fieldses.org> <20181210195347.GA4392@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.2 (3.30.2-2.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-12-10 at 14:53 -0500, J. Bruce Fields wrote:
> On Mon, Dec 10, 2018 at 02:23:10PM -0500, J. Bruce Fields wrote:
> > On Mon, Dec 10, 2018 at 01:12:31PM -0500, Jeff Layton wrote:
> > > On Mon, 2018-12-10 at 12:47 -0500, J. Bruce Fields wrote:
> > > > We've got a long-standing complaint that tools like lsof, when run on an
> > > > NFS server, overlook opens and locks held by NFS clients.
> > > > 
> > > > The information's all there, it's just a question of how to expose it.
> > > > 
> > > > Easiest might be a single flat file like /proc/locks, but I've always
> > > > hoped we could do something slightly more structured, using a
> > > > subdirectory per NFS client.
> > > > 
> > > > Jeff Layton looked into this several years ago.  I don't remember if
> > > > there was some particular issue or if he just got bogged down in VFS
> > > > details.
> > > > 
> > > 
> > > I think I had a patch that generated a single flat file for locks, but
> > > you wanted to present a directory or file per-client, and I just never
> > > got around to reworking the earlier patch.
> > 
> > Oh, OK, makes sense.
> 
> (But, um, if anyone has a good starting point to recommend to me here,
> I'm interested.  E.g. another pseudofs that's a good example to follow.)
> 

I looked for the branch, but I can't find it now. It may be possible to
find my original posting of it on the mailing list, but it has been
years. I'm pretty sure it'd be badly bitrotted by now anyway.

Where do you intend for this to live? Do you plan to build a new
hierarchy under /proc/fs/nfsd, or use something like sysfs or debugfs?

> I also had some idea that we might eventually also benefit from some
> two-way communication.  But the only idea I had there was some sort of
> "destroy this client now" operation, which is probably less important
> for NFSv4 state, since it gets cleaned up automatically on lease expiry.
> 

Per client cancellation sounds like a nice feature. The fault injection
code had some (less granular) stuff for killing off live clients. It may
be worth going over that.

-- 
Jeff Layton <jlayton@redhat.com>

