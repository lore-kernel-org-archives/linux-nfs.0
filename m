Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33953 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759208AbbIDSKX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 14:10:23 -0400
Received: by obcts10 with SMTP id ts10so23262693obc.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2015 11:10:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEmSD2wwu+M9UURq5MWOZTDqdp18TnmTSiQCc04mSvJmA@mail.gmail.com>
References: <CAN-5tyEmSD2wwu+M9UURq5MWOZTDqdp18TnmTSiQCc04mSvJmA@mail.gmail.com>
Date: Fri, 4 Sep 2015 14:10:22 -0400
Message-ID: <CAHQdGtRY7S=0kUKqT-FWApckRb_vvdpFk0RsNwjVajbUK2A6eg@mail.gmail.com>
Subject: Re: async CLOSE creates a race with a DELEGRETURN followed by a REMOVE
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 3, 2015 at 3:26 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>
> When file is opened with O_DIRECT, sending asynchronous CLOSE creates
> a race condition between CLOSE and DELEGRETURN followed REMOVE. Next
> operations are sent before the reply for CLOSE comes back which is
> according to the spec is not allowed (section 10.4.4). Server can get
> a REMOVE before the CLOSE and it causes EACCESS error to be returned
> because server thinks there is open state left.

BTW: What is generating an EACCES here? AFAIK, if the REMOVE returns
NFS4ERR_FILE_OPEN, then the client translates that as EBUSY (after
first retrying the REMOVE a couple of times).
