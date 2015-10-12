Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:32933 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbbJLTtT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2015 15:49:19 -0400
Received: by lbbk10 with SMTP id k10so41328109lbb.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2015 12:49:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <561BC61E.6010704@Netapp.com>
References: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
	<1444604337-17651-45-git-send-email-andreas.gruenbacher@gmail.com>
	<561BC61E.6010704@Netapp.com>
Date: Mon, 12 Oct 2015 21:49:17 +0200
Message-ID: <CAHc6FU6kp1pR8hRU3g2+A07xfpErMa3bNGJ47Sc4gEJS0U3nJQ@mail.gmail.com>
Subject: Re: [PATCH v10 44/46] nfs: Add richacl support
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>, xfs@oss.sgi.com,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anna,

On Mon, Oct 12, 2015 at 4:39 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> I'm not a fan of the "one giant function" approach.  Is there any way to split richacl_from_nfs4_acl() into several smaller functions?

sure, parsing the usr/group identifier could be put in a separate
function, for example.

That function cannot stay as it is right now anyway --- we really need
idmapper to tell us when an identifier string cannot be mapped to a
uid or gid so that we can preserve that identifier.

Thanks,
Andreas
