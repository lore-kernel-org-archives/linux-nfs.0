Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f42.google.com ([74.125.82.42]:53196 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab1LDMFC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:05:02 -0500
Received: by wgbds13 with SMTP id ds13so4656918wgb.1
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 04:05:01 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Sun, 4 Dec 2011 13:05:01 +0100
Message-ID: <CAGue13ruqa5mA+AELVSeR5Uxdb62mUsSxycOzZajzEZC6GP5Tw@mail.gmail.com>
Subject: [PATCH 0/2] nfsv41: add current_stateid processing
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

current_stateid processing will allow clients to construct compounds
like OPEN + READ + CLOSE or OPEN +LAYOUTGET.

As dCache server marks all layouts return-on-close, any open to a file followed
by LAYOUTGET. A combined compound will allow to do the same in one go.

Currently linux client doesn't support it. But before we can get such
functionality
linux server have to support it as well. Here is an attempt to add it.

I made a dirty test with pynfs with to test OPEN+CLOSE in a single compound.
If I read nfsd code correctly, READ and WRITE have to work as well. I
will refactor
pynfs a bit to easily construct such tests.

This is patches for preview to be sure that other server developers
are happy with
my approach before I change much more.

Tigran.
