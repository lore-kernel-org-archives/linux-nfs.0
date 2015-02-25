Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:56580 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751866AbbBYRFD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 12:05:03 -0500
Received: from tot-qpr-mailcore2.delacy.com ([172.27.56.106] helo=tot-qpr-mailcore2)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YQfOP-00064g-Sn
	for linux-nfs@vger.kernel.org; Wed, 25 Feb 2015 12:05:01 -0500
Received: from mail-yh0-f42.google.com ([209.85.213.42])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YQfOP-0006jB-My
	for linux-nfs@vger.kernel.org; Wed, 25 Feb 2015 12:05:01 -0500
Received: by yhaf73 with SMTP id f73so1591373yha.3
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 09:05:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
From: Chris Perl <cperl@janestreet.com>
Date: Wed, 25 Feb 2015 12:04:39 -0500
Message-ID: <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> That's expected behaviour, yes. NFS close-to-open cache consistency
> semantics do not allow for concurrent access while the file is being
> updated.

Can you elaborate on that a bit?

My rough understanding of close-to-open cache consistency is basically
that a clients changes are not guaranteed to be on the server until a
close(2) and that a client is only guaranteed to check for updates on
open(2).

I can therefore see why one client reading while another is appending
could result in stale data being read from the cache (and indeed, this
is the reason the test program I provided continually open and closes
the file, seeking as necessary).  But I'm having a hard time seeing
why close-to-open cache consistency allows for returning data from the
cache that never existed in the file.
