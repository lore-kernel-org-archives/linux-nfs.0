Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62F77C43219
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 18:17:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DB90A20685
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 18:17:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729393AbfDYSRP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 14:17:15 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:34449 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725970AbfDYSRP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2019 14:17:15 -0400
Received: by mail-qk1-f194.google.com with SMTP id n68so352173qka.1
        for <linux-nfs@vger.kernel.org>; Thu, 25 Apr 2019 11:17:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=e/PRYXN01EehGviOoC46SY2T7ECQiS7ZimbmrW1D6DE=;
        b=qrZO8IgCT1Wb9uIUVjrVv3LMSlfY/QU0bG0nTNIQoj4rE68qG9pxtM3OBeNNNEKrQK
         LZ2qeqOkbvGoUkLc/fJV24g627fPd9FrcVKoVxNw1nanbrAjeJnDFKozJunMRhV8NnQ2
         kTRCWEonosINVTFVWGGqokj+MNJYy8vk2NqHp/n7DltOGw0JPjZ4KtI/zemrYplIb2x1
         kTyyxjLNshy6AhBWWa9rlHa269Ikd7spxoxSTtwzR6jlIUaW+zbCvxZD7tloTAhGfeg6
         YdXqSCvJnMrtWBeQirWvmEDGPVMdw5INaSgd30ogkYOsrxefeFiQY3IDFHjv8CfRg9f9
         YQlA==
X-Gm-Message-State: APjAAAUDG7iekOOb5boqlGINBfBV3+FgushkFRWSKZC3pGQgsaq9eOF7
        Mbsrv0zUEfHgKma1g/qXF/vFdw==
X-Google-Smtp-Source: APXvYqzZYu6tAWyX4trqZ2/LthP5Zs+20KB+2+lyRngAUU0RK6YBob6i5J6UG6OBJRBqT0zPqxtX6w==
X-Received: by 2002:a37:73c3:: with SMTP id o186mr30873962qkc.71.1556216233800;
        Thu, 25 Apr 2019 11:17:13 -0700 (PDT)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-202A-0-0-0-83B.dyn6.twc.com. [2606:a000:1100:202a::83b])
        by smtp.gmail.com with ESMTPSA id a67sm11844656qkb.53.2019.04.25.11.17.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 11:17:13 -0700 (PDT)
Message-ID: <db0089a895463b4797d650002fbd4c1f091e1ec6.camel@redhat.com>
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
From:   Jeff Layton <jlayton@redhat.com>
To:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org
Date:   Thu, 25 Apr 2019 14:17:12 -0400
In-Reply-To: <1556201060-7947-1-git-send-email-bfields@redhat.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2019-04-25 at 10:04 -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The following patches expose information about NFSv4 opens held by knfsd
> on behalf of NFSv4 clients.  Those are currently invisible to userspace,
> unlike locks (/proc/locks) and local proccesses' opens (/proc/<pid>/).
> 
> The approach is to add a new directory /proc/fs/nfsd/clients/ with
> subdirectories for each active NFSv4 client.  Each subdirectory has an
> "info" file with some basic information to help identify the client and
> an "opens" directory that lists the opens held by that client.
> 
> I got it working by cobbling together some poorly-understood code I
> found in libfs, rpc_pipefs and elsewhere.  If anyone wants to wade in
> and tell me what I've got wrong, they're more than welcome, but at this
> stage I'm more curious for feedback on the interface.
> 
> I'm also cc'ing people responsible for lsof and util-linux in case they
> have any opinions.
> 
> Currently these pseudofiles look like:
> 
>   # find /proc/fs/nfsd/clients -type f|xargs tail 
>   ==> /proc/fs/nfsd/clients/3741/opens <==
>   5cc0cd36/6debfb50/00000001/00000001	rw	--	fd:10:13649	'open id:\x00\x00\x00&\x00\x00\x00\x00\x00\x00\x0b\xb7\x89%\xfc\xef'
>   5cc0cd36/6debfb50/00000003/00000001	r-	--	fd:10:13650	'open id:\x00\x00\x00&\x00\x00\x00\x00\x00\x00\x0b\xb7\x89%\xfc\xef'
> 
>   ==> /proc/fs/nfsd/clients/3741/info <==
>   clientid: 6debfb505cc0cd36
>   address: 192.168.122.36:0
>   name: Linux NFSv4.2 test2.fieldses.org
>   minor version: 2
> 
> Each line of the "opens" file is tab-delimited and describes one open,
> and the fields are stateid, open access bits, deny bits,
> major:minor:ino, and open owner.
> 
> So, some random questions:
> 
> 	- I just copied the major:minor:ino thing from /proc/locks, I
> 	  suspect we would have picked something different to identify
> 	  inodes if /proc/locks were done now.  (Mount id and inode?
> 	  Something else?)
> 
> 	- The open owner is just an opaque blob of binary data, but
> 	  clients may choose to include some useful asci-encoded
> 	  information, so I'm formatting them as strings with non-ascii
> 	  stuff escaped.  For example, pynfs usually uses the name of
> 	  the test as the open owner.  But as you see above, the ascii
> 	  content of the Linux client's open owners is less useful.
> 	  Also, there's no way I know of to map them back to a file
> 	  description or process or anything else useful on the client,
> 	  so perhaps they're of limited interest.
> 
> 	- I'm not sure about the stateid either.  I did think it might
> 	  be useful just as a unique identifier for each line.
> 	  (Actually for that it'd be enough to take just the third of
> 	  those four numbers making up the stateid--maybe that would be
> 	  better.)
> 
> In the "info" file, the "name" line is the client identifier/client
> owner provided by the client, which (like the stateowner) is just opaque
> binary data, though as you can see here the Linux client is providing a
> readable ascii string.
> 
> There's probably a lot more we could add to that info file eventually.
> 
> Other stuff to add next:
> 
> 	- nfsd/clients/#/kill that you can write to to revoke all a
> 	  client's state if it's wedged somehow.
> 	- lists of locks and delegations; lower priority since most of
> 	  that information is already in /proc/locks.
> 
> --b.
> 
> J. Bruce Fields (10):
>   nfsd: persist nfsd filesystem across mounts
>   nfsd: rename cl_refcount
>   nfsd4: use reference count to free client
>   nfsd: add nfsd/clients directory
>   nfsd: make client/ directory names small ints
>   rpc: replace rpc_filelist by tree_descr
>   nfsd4: add a client info file
>   nfsd4: add file to display list of client's opens
>   nfsd: expose some more information about NFSv4 opens
>   nfsd: add more information to client info file
> 
>  fs/nfsd/netns.h                |   6 +
>  fs/nfsd/nfs4state.c            | 228 ++++++++++++++++++++++++++++++---
>  fs/nfsd/nfsctl.c               | 225 +++++++++++++++++++++++++++++++-
>  fs/nfsd/nfsd.h                 |  11 ++
>  fs/nfsd/state.h                |   9 +-
>  fs/seq_file.c                  |  17 +++
>  include/linux/seq_file.h       |   2 +
>  include/linux/string_helpers.h |   1 +
>  lib/string_helpers.c           |   5 +-
>  net/sunrpc/rpc_pipe.c          |  37 ++----
>  10 files changed, 491 insertions(+), 50 deletions(-)
> 

I went through the patches and the code all looks fine to me. The only
real questions I think are what sort of info we want to present here,
and how we'll deal with changes to the format in the future.

Maybe on that latter point, we can reserve the right to add fields to
this info later, but do our best to never remove existing ones? Then
tools could be written to just ignore the fields that they don't
understand.

Reviewed-by: Jeff Layton <jlayton@redhat.com>

