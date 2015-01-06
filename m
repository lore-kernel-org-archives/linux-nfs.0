Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:60238 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbbAFXVW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:21:22 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so472752wid.17
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 15:21:20 -0800 (PST)
Date: Wed, 7 Jan 2015 00:21:17 +0100
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [pull request] nfs-utils: fixup detection of libtirpc
Message-ID: <20150106232117.GC17878@free.fr>
References: <cover.1420585444.git.yann.morin.1998@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <cover.1420585444.git.yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck, All,

Chuck, apologies: I mispelled your email when copying from the mail
archives. Sorry... :-(

Hopefuly, the committer can fix the 'Cc:' and 'Reported-by:' fields when
applying that series? If not, I'll respin...

On 2015-01-07 00:07 +0100, Yann E. MORIN spake thusly:
> Hello All!
> 
> This series is an ateempt to fix up the detection of libtirpc.
> 
> Since commit 8534063 (configure: use pkg-config to find libtirpc) (by me),
> some users are reporting that they can no longer build nfs-utils on older
> libtirpc versions.
> 
> Furthermore, after inspecting my own change, I saw thatI borked some of
> the tests: incorrect test when libtirpc is not required, and dropped
> check for authgss_free_private_data.
> 
> This series attempts to fix all those issues. Sorry for the mishap...
> 
> Regards,
> Yann E. MORIN.
> 
> 
> The following changes since commit fac4b7d30aafb6a02f66f29f0680db7b4894db79:
> 
>   mountstats: Updated the mountstats(8) man page. (2014-12-13 10:40:28 -0500)
> 
> are available in the git repository at:
> 
>   https://github.com/yann-morin-1998/nfs-utils.git yem/libtirpc-pkg-config
> 
> for you to fetch changes up to f3aaa3c4f47cd75629b60b913d97ef9d7dfd19ea:
> 
>   configure: restore checking for authgss_free_private_data in libtirpc (2015-01-06 23:58:22 +0100)
> 
> ----------------------------------------------------------------
> Yann E. MORIN (4):
>       configure: do not fail if libtirpc is missing but not requested
>       configure: be more laxist on the required libtirpc version
>       configure:restore the old way of checking for libtirpc
>       configure: restore checking for authgss_free_private_data in libtirpc
> 
>  aclocal/libtirpc.m4 | 44 +++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 41 insertions(+), 3 deletions(-)

Regards,
Yann E. MORIN.

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
