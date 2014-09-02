Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:49949 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaIBN7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 09:59:50 -0400
Message-ID: <5405CD51.9020601@gmail.com>
Date: Tue, 02 Sep 2014 16:59:45 +0300
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
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com> <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com> <5405A15F.2060002@gmail.com> <20140902132140.GA31793@fieldses.org>
In-Reply-To: <20140902132140.GA31793@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/02/2014 04:21 PM, Bruce Fields wrote:
> 
> You'd rather avoid sprinkling that all over, though.  If nothing else it
> increases the chances you'll suppress a legimate warning some day.
> 

But this is exactly why it was created.

If you do the "= 0" then it is gone forever. If you have missed a legitimate
needed assignment, it will be missed as well.

But if you do the uninitialized_var() dance then there is a make option that turns
it off and every once in a while people do a make with it to see if it still
holds.

The diff between foo = 0; and uninitialized_var(foo) is that the programmer is
communicating to his friends that:
	"I have encountered a bogus compiler, this is falsely initialized"

As opposed to =0 the compiler bug is covered up and forgotten

> And unless I'm missing something this one really does look like an
> unambiguous compiler bug.
> 

Right! so that is how you specify this in code at Linux: uninitialized_var(foo);

Putting =0 is way way worse, because it will never be revised and specially
not automatically with a make switch.

And leaving the warning on is even worse because two three of these and people
start to ignore warnings.

> --b.
> 

uninitialized_var was made to be a friend not an enemy, in the face of real
ugliness it is the best we can do. And that is what it should communicate to
everyone. Why has it become everyone's favorite blasphemy I do not know.

Cheers
Boaz

