Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46612 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757521Ab2C1LZU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 07:25:20 -0400
Received: by vcqp1 with SMTP id p1so616252vcq.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2012 04:25:20 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Wed, 28 Mar 2012 13:25:20 +0200
Message-ID: <CAGue13qo7JNJQJEkp5CqzveDMnbDnXsa8uDvYXK3UYZb3z-h3g@mail.gmail.com>
Subject: client keeps session after unmount
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Looks like current client

(6658a6991cef75719a21441aa0b7f8d6821534ee
git://linux-nfs.org/~trondmy/nfs-2.6.git)

keeps sessions to MDS and DS (periodic SEQUENCE ) after umount.
I can't see DESTROY_SESSION in packet trace.


100% reproducible.

Tigran.
