Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26257 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753112AbbAWPL6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 10:11:58 -0500
Message-ID: <54C264BA.30201@RedHat.com>
Date: Fri, 23 Jan 2015 10:11:54 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Yann E. MORIN" <yann.morin.1998@free.fr>, linux-nfs@vger.kernel.org
CC: Chuck Lever <check.lever@oracle.com>
Subject: Re: [pull request] nfs-utils: fixup detection of libtirpc
References: <cover.1420585444.git.yann.morin.1998@free.fr>
In-Reply-To: <cover.1420585444.git.yann.morin.1998@free.fr>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/06/2015 06:07 PM, Yann E. MORIN wrote:
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
> 
Committed... This restore the ability to compile the upstream nfs-utils
on legacy OSes by using the --disable-nfsv41 config flag

steved.
