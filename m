Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:36194 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbbH1VyN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2015 17:54:13 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrUoBnPyEGExpoDzHOCgnHh5=a1ROALmb63LLJZG+L=aQA@mail.gmail.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
	<1438689218-6921-4-git-send-email-agruenba@redhat.com>
	<CALCETrUoBnPyEGExpoDzHOCgnHh5=a1ROALmb63LLJZG+L=aQA@mail.gmail.com>
Date: Fri, 28 Aug 2015 23:54:11 +0200
Message-ID: <CAHpGcM+i887PJ07_CNZ38aK0DhRWgmyYbAGrDN2i1xXkH+1rUg@mail.gmail.com>
Subject: Re: [RFC v6 03/40] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD
 permission flags
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-08-28 23:36 GMT+02:00 Andy Lutomirski <luto@amacapital.net>:
> Silly question from the peanut gallery: is there any such thing as
> opening an fd pointing at a file such that the "open file description"
> (i.e. the struct file) captures the right to delete the file?
>
> IOW do we need FMODE_DELETE_SELF?

When would that permission be checked, what syscall would you use to
unlink an open file descriptor?

Thanks,
Andreas
