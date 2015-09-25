Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:35979 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525AbbIYQhg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 12:37:36 -0400
Received: by laclj5 with SMTP id lj5so9247697lac.3
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 09:37:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150924195939.GH3823@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-32-git-send-email-agruenba@redhat.com>
	<20150924195939.GH3823@fieldses.org>
Date: Fri, 25 Sep 2015 18:37:34 +0200
Message-ID: <CAHc6FU4Jk4daYPHFnTS9bs8UF5tdxyD+NwymOi8sGab3G6X-Jw@mail.gmail.com>
Subject: Re: [RFC v7 31/41] nfsd: Add support for the v4.1 dacl attribute
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-24 21:59 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> I'd probably move this up top with the other ACL case.

Okay.

Thanks,
Andreas
