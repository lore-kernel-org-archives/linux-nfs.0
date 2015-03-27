Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33268 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbbC0OIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 10:08:39 -0400
Received: by oifl3 with SMTP id l3so76848127oif.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 07:08:39 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 27 Mar 2015 10:08:39 -0400
Message-ID: <CAABAsM4jh3+S0YjNiSf8xdru0at5vUkvJRsTUDuoVupZNp+JUA@mail.gmail.com>
Subject: Re: pNFS layout, ROC and multiple opens
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 7:24 AM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
>
>
> Hi folks,
>
> we run into following issue:
>
> on a client host we have two processes - A and B.
> Process A opens a file and reads some data:
>
> OPEN -> LAYOUTGET -> READ.
> Notice, that layout has a roc set to true.
>
> Process B opens the same file:
>
> OPEN -> READ.
>
> Client obviously re-used layout information.
> Now, process A closes the file and as a result,
> layout becomes invalid.

No it doesn't. See the errata.

Cheers
  Trond
