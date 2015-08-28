Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:33174 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbbH1Vgg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2015 17:36:36 -0400
Received: by oigm66 with SMTP id m66so32167363oig.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2015 14:36:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1438689218-6921-4-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com> <1438689218-6921-4-git-send-email-agruenba@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 28 Aug 2015 14:36:15 -0700
Message-ID: <CALCETrUoBnPyEGExpoDzHOCgnHh5=a1ROALmb63LLJZG+L=aQA@mail.gmail.com>
Subject: Re: [RFC v6 03/40] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD
 permission flags
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 4, 2015 at 4:53 AM, Andreas Gruenbacher
<andreas.gruenbacher@gmail.com> wrote:
> Normally, deleting a file requires write and execute access to the parent
> directory.  With Richacls, a process with MAY_DELETE_SELF access to a file
> may delete the file even without write access to the parent directory.
>
> To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission()
> when checking for delete access inside a directory, and MAY_DELETE_SELF
> when checking for delete access to a file itelf.
>
> The MAY_DELETE_SELF permission does not override the sticky directory
> check.  It probably should.

Silly question from the peanut gallery: is there any such thing as
opening an fd pointing at a file such that the "open file description"
(i.e. the struct file) captures the right to delete the file?

IOW do we need FMODE_DELETE_SELF?

--Andy
