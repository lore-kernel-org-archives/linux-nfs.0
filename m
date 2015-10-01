Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34868 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbJAQzP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 12:55:15 -0400
Received: by ioiz6 with SMTP id z6so92227526ioi.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Oct 2015 09:55:14 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 1 Oct 2015 11:55:13 -0500
Message-ID: <CAOEg9Lo4N3ceJYV0=L-Khrh-oTFZUyTTS=X5acXTg9JKfe2_YA@mail.gmail.com>
Subject: Is UNSTABLE ever sent in client writes?
From: Constantine Peresypkin <pconstantine@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tried with various mount options (sync, async)
Looked into source code.
It seems like it will never be sent, client always assumes server can
do FILE_SYNC, and server cannot respond with anything else, if
implemented correctly.
But what we can do if the server is inherently unable to do FILE_SYNC
(eventual consistency, write reorder, etc.)?
