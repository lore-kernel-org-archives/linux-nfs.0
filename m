Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:36357 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450AbbIXPsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 11:48:22 -0400
Received: by lacao8 with SMTP id ao8so68467679lac.3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 08:48:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150924152851.GC3823@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-27-git-send-email-agruenba@redhat.com>
	<20150922191108.GC19127@fieldses.org>
	<20150923191832.GA29577@fieldses.org>
	<CAHc6FU4YkLJUAQEfH7CG8sAzXYbGzg_ibyT7m26Fc1p26v1=VQ@mail.gmail.com>
	<20150923203357.GC30521@fieldses.org>
	<CAHc6FU4Jh=-K5=DBERP3-vv8Sak4XGjVJgJ85mTeyPiApUhz+g@mail.gmail.com>
	<20150923210531.GC29349@fieldses.org>
	<CAHc6FU7W-oLTOqBxmzAOY5mM37-J6NcnXrhm2SnoDXqHBJbhRQ@mail.gmail.com>
	<20150924152851.GC3823@fieldses.org>
Date: Thu, 24 Sep 2015 17:48:20 +0200
Message-ID: <CAHc6FU4LW9vtuYSxE3Lj6o25O3NzVaFW8XC1kQy=d+KNixC5Bg@mail.gmail.com>
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

2015-09-24 17:28 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> I guess Samba's only choice on reading an ACL will be to split OWNER@
> ACEs into inheritable and effective parts and then replace the "who" on
> the latter by the current owner.

Right, that's when translating from richacls to Windows ACLs.

> On writing do you think it should try to translate ACEs for users
> matching the current owner to OWNER@ ACEs, or are you assuming it should
> leave those untouched?

In the other direction, from Windows ACLs to richacls, Samba at least
shouldn't have to do that mapping. There may still be cases where it
wants to do that mapping though.

Thanks,
Andreas
