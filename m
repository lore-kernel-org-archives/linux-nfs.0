Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:50642 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755622AbaICJON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 05:14:13 -0400
Received: by mail-ig0-f182.google.com with SMTP id a13so8735741igq.3
        for <linux-nfs@vger.kernel.org>; Wed, 03 Sep 2014 02:14:13 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 3 Sep 2014 11:14:13 +0200
Message-ID: <CALXu0Ue8mn5ERuDM0J7YNYcubm9NDf-bHKqvYXZgTn7Uz7LEDA@mail.gmail.com>
Subject: Accessing alternate data streams on NFSv4 server?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

is there any utility which can be used to access alternate data
streams (which can be accessed on Solaris via O_XATTR or newer
bash/ksh versions via cd -@) on Linux?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
