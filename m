From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Re: Kernel call trace on NFS-mount (using autofs).
Date: Tue, 20 May 2008 21:31:55 +0200
Message-ID: <4833272B.9030602@krogh.cc>
References: <48331EAE.6060107@krogh.cc> <1211311573.23156.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:51045 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137AbYETTcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 15:32:15 -0400
In-Reply-To: <1211311573.23156.10.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
  > That appears to be crashing in generic VFS code rather than in anything
> nfs specific, so I'd suggest reposting this Oops to linux-fsdevel. It
> would be nice if you could first try to reproduce it with 2.6.25,
> though.

Can I safely upgrade kernel to 2.6.25 without changing userspace utils
and autofs?

It is not particulary repoducible. I happens "every second day on a 
random node of a set of around 48".

-- 
Jesper
