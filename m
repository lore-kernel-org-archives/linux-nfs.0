Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f171.google.com ([209.85.128.171]:58401 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932313Ab3ICJdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 05:33:50 -0400
Received: by mail-ve0-f171.google.com with SMTP id pa12so3735828veb.2
        for <linux-nfs@vger.kernel.org>; Tue, 03 Sep 2013 02:33:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378145871-30071-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1378145871-30071-1-git-send-email-Trond.Myklebust@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Tue, 3 Sep 2013 11:33:30 +0200
Message-ID: <CAJ75kXbRgsYVRNobCmjeL-t+AJproq8jAxXkbkk9DxGnE9eYhQ@mail.gmail.com>
Subject: Re: [PATCH v2] NFS: Ensure that rmdir() waits for sillyrenames to complete
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>, andros@netapp.com,
        William Dauchy <william@gandi.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 2, 2013 at 8:17 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> If an NFS client does
>
>         mkdir("dir");
>         fd = open("dir/file");
>         unlink("dir/file");
>         close(fd);
>         rmdir("dir");
>
> then the asynchronous nature of the sillyrename operation means that
> we can end up getting EBUSY for the rmdir() in the above test. Fix
> that by ensuring that we wait for any in-progress sillyrenames
> before sending the rmdir() to the server.

I tested the patch on top of a 3.10.x
When doing heavy operations like rm -rf dir/ with lots of data, the
process gets stuck for ever.
removing the patch fixes the issue.

-- 
William
