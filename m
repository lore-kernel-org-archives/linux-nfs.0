Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:41651 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751937AbeAIAUo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jan 2018 19:20:44 -0500
Received: by mail-it0-f42.google.com with SMTP id b77so6389486itd.0
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jan 2018 16:20:44 -0800 (PST)
MIME-Version: 1.0
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Tue, 9 Jan 2018 01:20:43 +0100
Message-ID: <CAKwiHFjt_TkBzF1zo1AnmpPgCwP2FC1D3qoyHM_mB1-ZxL4TSQ@mail.gmail.com>
Subject: const laundering in nfs_parse_devname
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm playing around with some patches that will make strchr and friends
preserve constness (as in C++). Most of the fallout is trivially
fixable by changing a local "char *" to a "const char *". But in
nfs_parse_devname, there's a comma = strchr(dev_name, ',') after which
we may write to dev_name via comma, and I can't figure out if that's
ok. Does VFS expect the dev_name string to stay intact, or is the
constness mostly a matter of "you normally [won't have to/should not]
change this, but you can if you know what you're doing"?

Rasmus
