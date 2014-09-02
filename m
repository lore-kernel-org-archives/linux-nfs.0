Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36246 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526AbaIBQFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 12:05:53 -0400
Message-ID: <5405EADC.6080302@gmail.com>
Date: Tue, 02 Sep 2014 19:05:48 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Bruce Fields <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Shakil A Khan <shakilk1729@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        William Andros Adamson <andros@netapp.com>,
        Jeffrey Layton <jlayton@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for uninitizlized
 variable expire
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com> <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com> <5405A15F.2060002@gmail.com> <20140902132140.GA31793@fieldses.org> <5405CD51.9020601@gmail.com> <20140902141739.GB31793@fieldses.org>
In-Reply-To: <20140902141739.GB31793@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/02/2014 05:17 PM, Bruce Fields wrote:
> On Tue, Sep 02, 2014 at 04:59:45PM +0300, Boaz Harrosh wrote:
>> uninitialized_var was made to be a friend not an enemy, in the face of real
>> ugliness it is the best we can do. And that is what it should communicate to
>> everyone. Why has it become everyone's favorite blasphemy I do not know.
> 
> Not personally claiming it should never be used, just that this
> particular case is kind of extreme, since unless I'm missing a real
> compilication it's basically just:
> 
> 	if (ctx)
> 		assign to expire
> 	...
> 	if (ctx)
> 		use expire
> 
> A compiler wouldn't have to be that smart to actually prove to itself
> that expire is initialized at the last step, and that it's not only
> failing to do that but actually flagging it as possibly unitialized is
> weird.

Actually that is a complicated case for a compiler. Because of the two
different scopes. I think it only optimizes that on higher optimization
values. Cross scope analysis is not done at parsing time but more on
code generation time, the "warning" is more of the former phase.

Perhaps change the code, if possible, so the assign and use of "expire"
is under the last if (or the first)? That would be also easier on the
reader.

BTW: You are most probably right though, because here I do not have this
     problem. I guess it is the case of an old compiler with a certain
     compilation environment.

Thanks
Boaz

> 
> --b.
> 

