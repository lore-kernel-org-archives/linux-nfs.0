Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34445 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756146AbbKDCTe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 21:19:34 -0500
Received: by lbbwb3 with SMTP id wb3so5745488lbb.1
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2015 18:19:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6A710DA3-0B03-4371-A1EB-7AF39F684EDC@dilger.ca>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
	<1446563847-14005-21-git-send-email-agruenba@redhat.com>
	<6A710DA3-0B03-4371-A1EB-7AF39F684EDC@dilger.ca>
Date: Wed, 4 Nov 2015 03:19:32 +0100
Message-ID: <CAHc6FU5hzeEc96go331s49CMHq=_PoxduGtuakcHPp441hEzSQ@mail.gmail.com>
Subject: Re: [PATCH v13 20/51] ext4: Add richacl support
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 4, 2015 at 3:13 AM, Andreas Dilger <adilger@dilger.ca> wrote:
> Patch looks reasonable.  One minor cleanup below that could be fixed when
> the patch series is refreshed, and you can add:
>
> Reviewed-by: Andreas Dilger <adilger@dilger.ca>

Okay, thank you.

Andreas
