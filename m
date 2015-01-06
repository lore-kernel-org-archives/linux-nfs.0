Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:35568 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbbAFXIA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:08:00 -0500
Received: by mail-we0-f176.google.com with SMTP id w61so183571wes.35
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 15:07:59 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <check.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        "Yann E. MORIN" <yann.morin.1998@free.fr>
Subject: [pull request] nfs-utils: fixup detection of libtirpc 
Date: Wed,  7 Jan 2015 00:07:56 +0100
Message-Id: <cover.1420585444.git.yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello All!

This series is an ateempt to fix up the detection of libtirpc.

Since commit 8534063 (configure: use pkg-config to find libtirpc) (by me),
some users are reporting that they can no longer build nfs-utils on older
libtirpc versions.

Furthermore, after inspecting my own change, I saw thatI borked some of
the tests: incorrect test when libtirpc is not required, and dropped
check for authgss_free_private_data.

This series attempts to fix all those issues. Sorry for the mishap...

Regards,
Yann E. MORIN.


The following changes since commit fac4b7d30aafb6a02f66f29f0680db7b4894db79:

  mountstats: Updated the mountstats(8) man page. (2014-12-13 10:40:28 -0500)

are available in the git repository at:

  https://github.com/yann-morin-1998/nfs-utils.git yem/libtirpc-pkg-config

for you to fetch changes up to f3aaa3c4f47cd75629b60b913d97ef9d7dfd19ea:

  configure: restore checking for authgss_free_private_data in libtirpc (2015-01-06 23:58:22 +0100)

----------------------------------------------------------------
Yann E. MORIN (4):
      configure: do not fail if libtirpc is missing but not requested
      configure: be more laxist on the required libtirpc version
      configure:restore the old way of checking for libtirpc
      configure: restore checking for authgss_free_private_data in libtirpc

 aclocal/libtirpc.m4 | 44 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 41 insertions(+), 3 deletions(-)

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
