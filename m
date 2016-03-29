Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34475 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbcC2T5y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2016 15:57:54 -0400
Received: by mail-io0-f177.google.com with SMTP id e3so39074141ioa.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Mar 2016 12:57:54 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 29 Mar 2016 15:57:53 -0400
Message-ID: <CAN-5tyE_Y8gw9MrCwXpY-zjE2b7sdFGTTWMcO6pOZgo4HAy8AA@mail.gmail.com>
Subject: out of order v3 write replies and cache invalidation
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is it always the case that cache invalidation is unavoidable when
client receives out of order replies back from the server? I believe
it is because the change attribute mismatch is unavoidable but I'd
like to check if my understanding is correct.

Here's what I mean:
1 write call 0-1024
2 write call 1024-2048
3 write call 2048-4096
4 write reply to 1
5 write reply to 3
6 write reply to 2

When #5 is received in the "before" attributes it doesn't have the
"after" attributes of reply #4 and that leads to cache invalidation
(this is what I'm seeing in the current code).

Thank you.
