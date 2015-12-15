Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:33682 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964925AbbLOLMR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Dec 2015 06:12:17 -0500
Received: by mail-lb0-f175.google.com with SMTP id kw15so3381275lbb.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Dec 2015 03:12:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449090088-9281-1-git-send-email-agruenba@redhat.com>
References: <1449090088-9281-1-git-send-email-agruenba@redhat.com>
Date: Tue, 15 Dec 2015 12:12:15 +0100
Message-ID: <CAHc6FU6AdiKzxNDZu3xpEUMa0TTKHkDSQtn7SopCHm1zZF3cAQ@mail.gmail.com>
Subject: Re: [PATCH v16 00/22] Richacls (Core and Ext4)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An updated version of the richacl patches rebased on top of the recent
xattr cleanups (Al's work.xattr branch) is available here:

   git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
         richacl-2015-12-15

Thanks,
Andreas
