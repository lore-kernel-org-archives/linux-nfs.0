Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:36333 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbbIBGIq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2015 02:08:46 -0400
MIME-Version: 1.0
In-Reply-To: <20150901213816.GH10468@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
	<1438689218-6921-10-git-send-email-agruenba@redhat.com>
	<20150901213816.GH10468@fieldses.org>
Date: Wed, 2 Sep 2015 08:08:43 +0200
Message-ID: <CAHpGcMK2rp4SCtNzkhWoHZWBWr2GRMTNxwtP3_VsN__WCeGtFA@mail.gmail.com>
Subject: Re: [RFC v6 09/40] richacl: Update the file masks in chmod()
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-01 23:38 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> Do you need to require WRITE_THROUGH here too?

Yes, indeed.

Thanks,
Andreas
