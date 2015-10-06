Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:34728 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbbJFMkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 08:40:03 -0400
Received: by lbbwt4 with SMTP id wt4so37700018lbb.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 05:40:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151006090746.GA27791@xo-6d-61-c0.localdomain>
References: <1444073830-21854-1-git-send-email-agruenba@redhat.com>
	<20151006090746.GA27791@xo-6d-61-c0.localdomain>
Date: Tue, 6 Oct 2015 14:40:01 +0200
Message-ID: <CAHc6FU79km84DAg+-EHkwyBf3Wq-e5AhBYQ1eXdS8mDpmPR0ow@mail.gmail.com>
Subject: Re: [PATCH v9 00/43] Richacls
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Pavel Machek <pavel@ucw.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 6, 2015 at 11:07 AM, Pavel Machek <pavel@ucw.cz> wrote:
> Should there be file in Documentation/ explaining how this works?

There are plenty of comments in the code and in the patch descriptions
that describe how the code works. The user-space package has manual
pages that describe how to use richacls; this information would not be
accessible to users when put in Documentation/. Also, some background
information is available on http://www.bestbits.at/richacl/.

Thanks,
Andreas
