Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:34077 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753212AbbBYVCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 16:02:48 -0500
Received: from tot-qpr-mailcore2.delacy.com ([172.27.56.106] helo=tot-qpr-mailcore2)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YQj6V-0001dW-A5
	for linux-nfs@vger.kernel.org; Wed, 25 Feb 2015 16:02:47 -0500
Received: from mail-yk0-f180.google.com ([209.85.160.180])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YQj6V-0004JG-4d
	for linux-nfs@vger.kernel.org; Wed, 25 Feb 2015 16:02:47 -0500
Received: by ykp131 with SMTP id 131so2123763ykp.3
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 13:02:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com> <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
From: Chris Perl <cperl@janestreet.com>
Date: Wed, 25 Feb 2015 16:02:26 -0500
Message-ID: <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> So imagine 2 WRITE calls that are being sent to an initially empty
> file. One WRITE call is for offset 0, and length 4096 bytes. The
> second call is for offset 4096 and length 4096 bytes.
> Imagine now that the first WRITE gets delayed (either because the page
> cache isn't flushing that part of the file yet or because it gets
> re-ordered in the RPC layer or on the server), and the second WRITE is
> received and processed by the server first.
> Once the delayed WRITE is processed there will be data at offset 0,
> but until that happens, anyone reading the file on the server will see
> a hole of length 4096 bytes.
>
> This kind of issue is why close-to-open cache consistency relies on
> only one client accessing the file on the server when it is open for
> writing.

Fair enough.  I am taking note of the fact that you said "This kind of
issue" implying there are probably other subtle cases I'm not thinking
about or that your example does not illustrate.

That said, in your example, there exists some moment in time when the
file on the server actually does have a hole in it full of 0's.  In my
case, the file never contains 0's.

To be fair, when testing with an Isilon, I can't actually inspect the
state of the file on the server in any meaningful way, so I can't be
certain that's true.  But, from the view point of the reading client
at the NFS layer there are never 0's read back across the wire.  I've
confirmed this by matching up wireshark traces while reproducing and
the READ reply's never contain 0's.  The 0's manifest due to reading
too far past where there is valid data in the page cache.

Does this still fall under the "not expected to work" category because
of the close-to-open issues you explained, or is there perhaps
something to fix here because its entirely on the reading client side?
