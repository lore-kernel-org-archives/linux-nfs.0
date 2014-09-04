Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:53168 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbaIDLZO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 07:25:14 -0400
Received: by mail-ig0-f169.google.com with SMTP id r2so849811igi.4
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 04:25:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <540831FE.1010208@rug.nl>
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
	<540831FE.1010208@rug.nl>
Date: Thu, 4 Sep 2014 13:25:13 +0200
Message-ID: <CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
Subject: Re: How to use NFS with multiple principals in different realms?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Jurjen Bokma <j.bokma@rug.nl>
Cc: "<kerberos@mit.edu>" <kerberos@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4 September 2014 11:33, Jurjen Bokma <j.bokma@rug.nl> wrote:
> You use cross realm authentication, so that your NFS client may obtain
> tickets for servers that are not in its own realm.

What if I cannot use cross realm authentication? For example if both
realms do not like each other?
What if I really have to kinit into multiple realms? Kerberos since
1.10 can do that and klist now has a new flag -A to list all entries
if KRB5CCNAME points to a directory, e.g.
KRB5CCNAME=DIR:/tmp/krbcc$UID/

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
