Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35417 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbbE1V2O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 17:28:14 -0400
MIME-Version: 1.0
In-Reply-To: <20150528203332.GD31663@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
	<8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
	<20150528203332.GD31663@fieldses.org>
Date: Thu, 28 May 2015 23:28:13 +0200
Message-ID: <CAHpGcM+2im13QoL=q4Z1vje+ytiNuGhqtaKHycgQ7E=EbvZb+g@mail.gmail.com>
Subject: Re: [RFC v3 36/45] NFSv4: Fix GETATTR bitmap verification
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-28 22:33 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> This is the same list as in nfs4-xdr_enc_server_caps.  Could we avoid
> that duplication?

I don't think it matters at all.

Thanks,
Andreas
