Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34653 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760286AbbIDUjp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 16:39:45 -0400
Received: by obcts10 with SMTP id ts10so26129475obc.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2015 13:39:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DA83C389-2E91-4A35-ACF5-F14F33D50944@oracle.com>
References: <1441394647-16412-1-git-send-email-trond.myklebust@primarydata.com>
	<DA83C389-2E91-4A35-ACF5-F14F33D50944@oracle.com>
Date: Fri, 4 Sep 2015 16:39:44 -0400
Message-ID: <CAHQdGtQJEvrwQP_J1xEnzg96YmHbK2LKHDrkYOsaE+pna4Z78w@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFS: Optimise away the close-to-open getattr if there
 is no cached data
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 4, 2015 at 3:38 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Sep 4, 2015, at 3:24 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> If there is no cached data, then there is no need to track the file
>> change attribute on close.
>
> This makes sense. nfs_close_context() is only used by NFSv2
> and NFSv3.
>
> Should you update the documenting comment?

Good point. I'll do that...
