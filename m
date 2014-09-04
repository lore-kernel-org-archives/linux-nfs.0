Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35311 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbaIDJE2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 05:04:28 -0400
Received: by mail-ie0-f172.google.com with SMTP id rd18so11232857iec.31
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 02:04:28 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 4 Sep 2014 11:04:27 +0200
Message-ID: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
Subject: How to use NFS with multiple principals in different realms?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: "<kerberos@mit.edu>" <kerberos@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How can I use NFS with kerberos krb5p auth when I want to use NFS
filesystems which come from different realms?

I know klist -A can show all tickets I got from all realms I kinit to
- but how can NFS use them?

OS is RHEL7

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
