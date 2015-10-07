Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36055 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279AbbJGNq5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 09:46:57 -0400
Received: by lbcao8 with SMTP id ao8so11844762lbc.3
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 06:46:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.20.1510071832320.20498@namei.org>
References: <1444073830-21854-1-git-send-email-agruenba@redhat.com>
	<20151006090746.GA27791@xo-6d-61-c0.localdomain>
	<CAHc6FU79km84DAg+-EHkwyBf3Wq-e5AhBYQ1eXdS8mDpmPR0ow@mail.gmail.com>
	<alpine.LRH.2.20.1510071832320.20498@namei.org>
Date: Wed, 7 Oct 2015 15:46:55 +0200
Message-ID: <CAHc6FU4ZWjR0CaP_ygHYq2SDZ3sdsWfNRtj0f5GTK3a-GrezGg@mail.gmail.com>
Subject: Re: [PATCH v9 00/43] Richacls
From: Andreas Gruenbacher <agruenba@redhat.com>
To: James Morris <jmorris@namei.org>
Cc: Pavel Machek <pavel@ucw.cz>, Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 7, 2015 at 9:33 AM, James Morris <jmorris@namei.org> wrote:
> Are many distros planning on enabling this?  I gather RH is...

It's a per-filesystem feature, so it's the admin's choice (if compiled
in). On ext4, you have to set the richacl feature flag to get Richacls
instead of POSIX ACLs.

Andreas
