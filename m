Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.mera.ru ([195.98.57.161]:50937 "EHLO mail.mera.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab2AZLPE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 06:15:04 -0500
Received: from [192.168.20.11] (helo=tecas.te.mera.ru)
	by mail.mera.ru with esmtps (TLSv1:AES128-SHA:128)
	(Exim 4.71 (FreeBSD))
	(envelope-from <vvlasov@mera.ru>)
	id 1RqNIF-000Gxw-0s
	for linux-nfs@vger.kernel.org; Thu, 26 Jan 2012 15:15:03 +0400
From: "Vlasov, Vladimir" <vvlasov@mera.ru>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re-init lockd and kstatd in runtime.
Date: Thu, 26 Jan 2012 11:15:02 +0000
Message-ID: <06EFEBD57610DE4FBCA0449DDF4E102B08765D@tecas.te.mera.ru>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

I'm wondering if there is any way to re-init lockd and kstatd after startup?

Look, in svc.c static variable nsm_use_kstatd is set to 1.
Then, if nsm_kernel_statd_init() returns error, nsm_use_kstatd is set to 0.
And we end up without kstatd.

Lockd will exit as soon as last NFS mount is unmounted and on next mount attempt lockd() in svc.c will be called again, but nsm_use_kstatd is 0 already and kstatd init will be skipped.

So, looks like if /var/lib/nfs/state is missed on host startup, there is no way to recover and tell kernel init kstatd later on demand. Or?

Best regards
Vladimir Vlasov
