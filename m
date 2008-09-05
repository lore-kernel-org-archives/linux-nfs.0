From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/16] nfs-utils: make makesock() static
Date: Thu, 4 Sep 2008 21:40:31 -0400
Message-ID: <76bd70e30809041840r6bbf383coa9fef85cafeefff3@mail.gmail.com>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
	 <20080904165658.1471.56972.stgit@manray.1015granger.net>
	 <18624.34805.396033.544222@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:51380 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbYIEBkd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 21:40:33 -0400
Received: by mu-out-0910.google.com with SMTP id g7so162126muf.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2008 18:40:31 -0700 (PDT)
In-Reply-To: <18624.34805.396033.544222-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 4, 2008 at 9:14 PM, Neil Brown <neilb@suse.de> wrote:
> On Thursday September 4, chuck.lever@oracle.com wrote:
>>
>>  o  Return RPC_ANYSOCK on error (this is -1) instead of open-coding -1.
>
> I don't agree with this change.
>
> Everything else (including the last) looks fine, though I personally
> wouldn't bother closing file descriptors and freeing memory just
> before exit.

If nothing else, it makes interpreting the output of valgrind easier.  :-)

Code in nfs-utils seems to last many many years, and is copied and
pasted a lot without regard to context (ie code that may have been
written for a single-shot application may suddenly find itself
embedded in a long-running daemon).  Considering that parts of
nfs-utils are used in HA environments, I'd rather be safe then sorry.

> RPC_ANYSOCK is an input value to various rpc library functions which
> means "I haven't opened a socket, you do it for me".  It is not really
> a valid return value.

Well, FWIW it is treated as a return value by
utils/mount/network.c:get_socket() and it's callers.

> Every time makesock is called, the return status is tested with
>     if (makesock(...) < 0)
>
> To me, that says that the returned value should be e.g. -1, not
> RPC_ANYSOCK.

OK, I'll drop it.  Thanks for the review.

--
Chuck Lever
