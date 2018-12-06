Return-Path: <SRS0=YXm+=OP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 043BFC04EB8
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 04:17:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE7D82146D
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 04:17:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NBVohVqd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE7D82146D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728941AbeLFERA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 23:17:00 -0500
Received: from mail-yb1-f194.google.com ([209.85.219.194]:46581 "EHLO
        mail-yb1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728219AbeLFEQ7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 23:16:59 -0500
Received: by mail-yb1-f194.google.com with SMTP id l126so6142973ybf.13;
        Wed, 05 Dec 2018 20:16:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=r/MO53q4wXTc3kVKGX7Fkfx6JjNsJcPndMfcQA5GsNM=;
        b=NBVohVqdjNMgylr7pZOvyW3Nud5HQr6fNo6WYzndaKENQuhJ/KVxA3RdT5clAwIGi0
         Dg5H5c3JY8/l4rCcC04xzOQFz4IzfCA3j+cffs2Ibub2/y3qpOC+8yjrsH5ryp8ZdjFG
         E1gjjYvdEwJ6szOM1X1ZCaBwvKIHq4UcBwEV/mMg6vPi/cteiPhHhg9Cc5k8gPCtTGnJ
         hoeQNwo0xS/ttH883e6IJvoJjSB+UGNTz8fBhZld8b7c3X0Yv0JFSZtaTL6WS//b3ZiT
         K8OzaCVdQ82QZ4MrtKaRq+5nHzhOP+AnUuB/1meh3Ji1x44yZfedY6w91+MzyX21aECe
         5JEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=r/MO53q4wXTc3kVKGX7Fkfx6JjNsJcPndMfcQA5GsNM=;
        b=bVCmK4X6nlkpGEGjUHBMHKjgozBSYD3MQfCkg7RgyyPJXUfXxts1HOnKbcWaDfvlaR
         QFy21H4XC7mnU3/0wSjoXzz+X4/q3rqFaXM7/V/VsTbCJJz9x+KGACKed5/JBO43dah9
         j10F20iggII927P09lHie8fUkKTX4nclhqixMBgz0J/22hzgaLy62KyDmHzOEdO5XaRZ
         ssbZEup0PjJrjBHGnpwCMEFSZ36f1KfwaKoZKc0+YWWcZnljEwwPjmgLsi32ux89KmS9
         Mk3kr89VdBZ4f+Udo6YZxHlpwWbuA/vOmFV+Dx9TJMVBnQ8PDrFqq3N9ZAJ0seZNLoQO
         xC5g==
X-Gm-Message-State: AA+aEWZghs+DfXocvkybTqvWJl0e5R/W/laLYPL5a7Q6d/WAYhY3d5L0
        qPp6b4C2fnfC9H+z8GWotD12TxDNN7bQuwM/CqeV7Ptx
X-Google-Smtp-Source: AFSGD/U5HL5tnjhcXO0zKaaaEqhfS1iCt5SsEWSMNh0h0GvbyuW0+a7BwUuNIP9e5blTCgcbKncHyT+/3a/SpsjIMiY=
X-Received: by 2002:a81:3558:: with SMTP id c85mr26667663ywa.34.1544069818210;
 Wed, 05 Dec 2018 20:16:58 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-4-david@fromorbit.com>
 <CAOQ4uxjRErxoOTAr+yzu7s5S4SEYZuw6GcfQ-M7UXAasTG9Knw@mail.gmail.com> <20181203230222.GH6311@dastard>
In-Reply-To: <20181203230222.GH6311@dastard>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 6 Dec 2018 06:16:46 +0200
Message-ID: <CAOQ4uxgqaGoVs9t9NqWn-uVyeeZzZOUBSYX6=JFn2uCf3rKmUQ@mail.gmail.com>
Subject: Re: [PATCH 03/11] vfs: no fallback for ->copy_file_range
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 4, 2018 at 1:02 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Mon, Dec 03, 2018 at 12:22:21PM +0200, Amir Goldstein wrote:
> > On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > From: Dave Chinner <dchinner@redhat.com>
> > >
> > > Now that we have generic_copy_file_range(), remove it as a fallback
> > > case when offloads fail. This puts the responsibility for executing
> > > fallbacks on the filesystems that implement ->copy_file_range and
> > > allows us to add operational validity checks to
> > > generic_copy_file_range().
> > >
> > > Rework vfs_copy_file_range() to call a new do_copy_file_range()
> > > helper to exceute the copying callout, and move calls to
> > > generic_file_copy_range() into filesystem methods where they
> > > currently return failures.
> > >
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> >
> > You may add
> > Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> >
> > After fixing the overlayfs issue below.
> > ...
> >
> > > diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> > > index 84dd957efa24..68736e5d6a56 100644
> > > --- a/fs/overlayfs/file.c
> > > +++ b/fs/overlayfs/file.c
> > > @@ -486,8 +486,15 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
> > >                                    struct file *file_out, loff_t pos_out,
> > >                                    size_t len, unsigned int flags)
> > >  {
> > > -       return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
> > > +       ssize_t ret;
> > > +
> > > +       ret =  ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
> > >                             OVL_COPY);
> > > +
> > > +       if (ret == -EOPNOTSUPP)
> > > +               ret = generic_copy_file_range(file_in, pos_in, file_out,
> > > +                                       pos_out, len, flags);
> > > +       return ret;
> > >  }
> > >
> >
> > This is unneeded, because ovl_copyfile(OVL_COPY) is implemented
> > by calling vfs_copy_file_range() (on the underlying files) and it is
> > not possible
> > to get EOPNOTSUPP from vfs_copy_file_range().
>
> Except that it is possible. e.g. If the underlying filesystem tries
> a copy offload, gets a "not supported" failure from the remote
> server and then doesn't implement a fallback.
>

I'm in the opinion that ovl_copy_file_range() and do_copy_file_range()
are a like. If you choose not to fallback in the latter to
generic_copy_file_range() for misbehaving filesystem and WARN_ON
this case, there is no reason for overlayfs to cover up for the
misbehaving underlying filesystem.

If you want to cover up for misbehaving filesystem, please do it
in do_copy_file_range() and drop the WARN_ON_ONCE().
Come to think about it, I understand your reasoning for pushing
generic_copy_file_range() down to filesystems so they can fallback to
it in several error conditions.
I do not follow the reasoning of NOT falling back to
generic_copy_file_range() in vfs if EOPNOTSUPP is returned from
filesystem. IOW, if we want to cover up for misbehaving filesystem,
this would have been a more robust code:

+static ssize_t do_copy_file_range(struct file *file_in, loff_t pos_in,
+                           struct file *file_out, loff_t pos_out,
+                           size_t len, unsigned int flags)
+{
+       ssize_t ret;
+
+       if (file_out->f_op->copy_file_range) {
+               ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
+                                                     pos_out, len, flags);
+               if (!WARN_ON_ONCE(ret == -EOPNOTSUPP))
+                       return ret;
+       }
+       return generic_copy_file_range(file_in, &pos_in, file_out, &pos_out,
+                                       len, flags);
+}
+

Thanks,
Amir.
