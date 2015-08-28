Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33330 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841AbbH1VID (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2015 17:08:03 -0400
Received: by lbbsx3 with SMTP id sx3so36874801lbb.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2015 14:08:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150828204413.GB23326@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
	<1438689218-6921-4-git-send-email-agruenba@redhat.com>
	<20150828204413.GB23326@fieldses.org>
Date: Fri, 28 Aug 2015 23:08:00 +0200
Message-ID: <CAHc6FU41cZWJZ=4EZmBKwfhM4HPDBG9Gxuq9DUeLt2t0Lq4B=Q@mail.gmail.com>
Subject: Re: [RFC v6 03/40] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD
 permission flags
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-08-28 22:44 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> The MAY_DELETE_SELF permission does not override the sticky
>> directory check.  It probably should.
>
> I guess it would basically just let the file owner delegate permission
> to delete your file to a non-owner?  Makes sense to me to allow that.

Yes, independent of whether or not the process has MAY_DELETE_CHILD
access on the directory but not independent of the sticky directory
check, which is a bit of a weird combination.

Andreas
