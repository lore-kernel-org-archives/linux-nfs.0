Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:35789 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186AbbIWUkU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 16:40:20 -0400
Received: by lagj9 with SMTP id j9so65305053lag.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 13:40:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150923203357.GC30521@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-27-git-send-email-agruenba@redhat.com>
	<20150922191108.GC19127@fieldses.org>
	<20150923191832.GA29577@fieldses.org>
	<CAHc6FU4YkLJUAQEfH7CG8sAzXYbGzg_ibyT7m26Fc1p26v1=VQ@mail.gmail.com>
	<20150923203357.GC30521@fieldses.org>
Date: Wed, 23 Sep 2015 22:40:18 +0200
Message-ID: <CAHc6FU4Jh=-K5=DBERP3-vv8Sak4XGjVJgJ85mTeyPiApUhz+g@mail.gmail.com>
Subject: Re: [RFC v7 26/41] richacl: Apply the file masks to a richacl
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-23 22:33 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> The same could be said if there's a group-i-belong-to:rwx::allow entry,
> do we make that exception too?

We cannot because that would be incorrect for all other group members.

Andreas
