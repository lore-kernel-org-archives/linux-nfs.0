Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:35599 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170AbbIBUXF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2015 16:23:05 -0400
Received: by lagj9 with SMTP id j9so15417897lag.2
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2015 13:23:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150902192008.GB3319@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
	<1438689218-6921-3-git-send-email-agruenba@redhat.com>
	<20150902185300.GA3319@fieldses.org>
	<CAHc6FU62LQ8xnEbjsBprnud36AURg_ggifFoHOVM51-9vRJeDg@mail.gmail.com>
	<20150902192008.GB3319@fieldses.org>
Date: Wed, 2 Sep 2015 22:23:03 +0200
Message-ID: <CAHc6FU4L3e=OuH8_22zBgC45x0z77HDq9PqrgQ02hy3+vVYhRw@mail.gmail.com>
Subject: Re: [RFC v6 02/40] vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR
 permission flags
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-02 21:20 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> Got it.  And maybe it should be obvious, but it might be worth a
> sentence in the changelog if it's not already explained elsewhere.--b.

Let me try adding a comment. Also I'll fix the next commit which adds
MAY_DELETE_SELF here: MAY_DELETE_SELF shouldn't go together with
MAY_WRITE.

Thanks,
Andreas
