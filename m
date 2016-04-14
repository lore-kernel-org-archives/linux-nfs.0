Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33995 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbcDNSlu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2016 14:41:50 -0400
Received: by mail-io0-f169.google.com with SMTP id 2so112866705ioy.1
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 11:41:50 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 14 Apr 2016 14:41:49 -0400
Message-ID: <CAN-5tyH-ATtHtWuw4t07DjZnnzOit=rQ=H0vq+W04gU=Ys=b+g@mail.gmail.com>
Subject: gssd and linux containers
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Does somebody know if it's possible to do secure mounts within linux
containers? I seem to recall that gssd is not container-aware. Or is
container-magic makes it so that gssd runs per container and has its
own dedicated krb5.conf+keytab configurations?

Thank you.
