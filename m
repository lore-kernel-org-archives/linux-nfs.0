Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33123 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934467AbbGVQIM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 12:08:12 -0400
MIME-Version: 1.0
In-Reply-To: <55AFBD84.5040904@Netapp.com>
References: <1437570209-29832-1-git-send-email-andreas.gruenbacher@gmail.com>
	<1437570209-29832-40-git-send-email-andreas.gruenbacher@gmail.com>
	<55AFBD84.5040904@Netapp.com>
Date: Wed, 22 Jul 2015 18:08:10 +0200
Message-ID: <CAHpGcMKc4Dt6sFY5O5=o2f=jV_SwQ9jM39pFin9mjn_FtXf+AA@mail.gmail.com>
Subject: Re: [PATCH v5 39/39] nfs: Add support for the v4.1 dacl attribute
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

2015-07-22 17:57 GMT+02:00 Anna Schumaker <Anna.Schumaker@netapp.com>:
> Discussions around deprecating or removing the minorversion= argument have come up recently.
> The preferred way of mounting NFS v4.1 these days is with: "-o vers=4.1".  Can you update your
> patch description so we don't confuse people? :)

sure, that was easy :)

Thanks,
Andreas
