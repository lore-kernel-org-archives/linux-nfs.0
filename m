Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:45949 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388006AbeGTTds (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jul 2018 15:33:48 -0400
Received: by mail-vk0-f51.google.com with SMTP id b78-v6so6514276vka.12
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jul 2018 11:44:17 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 20 Jul 2018 14:44:16 -0400
Message-ID: <CAN-5tyHi8g-WS451xrGOfgjaSzthVKYwdLK77Cy+Bah_2qF+KA@mail.gmail.com>
Subject: Another question about v3 attribute handling
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

This is a different question but is related to the attribute handling.

What I see in v4, is that say the client received a reply to the OPEN
with before and after change_attr values for the directory. We check
if the before value is the same as what we have in the cache and if
it's not then we invalidate the directory attributes.

It seems that we don't have similar check for the v3. If in v3, the
server returned a before that was different from what could be seen on
the network trace as the before for the directory, it does not trigger
invalidation. Is this expected because it's v3 or is this a bug?
