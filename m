Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:61208 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbaJFNsa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 09:48:30 -0400
Received: by mail-ie0-f182.google.com with SMTP id rp18so3364195iec.13
        for <linux-nfs@vger.kernel.org>; Mon, 06 Oct 2014 06:48:29 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 6 Oct 2014 09:48:29 -0400
Message-ID: <CAN-5tyF4oCkmHskT02GceF=CR1mYZc3uwm0tLf2fd39-XeyjRg@mail.gmail.com>
Subject: [bug] open owner value is always the same
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The spec says that open owner needs to be different for different
files yet the code returns the same value.

It is not clear to me what's broken about ida_get_new() that's used
for generation of the owner ids.

Can somebody comment on this?

Thank you.
