Return-Path: <SRS0=byNy=QC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 676B9C282C5
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Jan 2019 08:39:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 29D9A218A6
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Jan 2019 08:39:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CBecMT+3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726174AbfAZIjk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 26 Jan 2019 03:39:40 -0500
Received: from mail-oi1-f196.google.com ([209.85.167.196]:46022 "EHLO
        mail-oi1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726122AbfAZIjk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Jan 2019 03:39:40 -0500
Received: by mail-oi1-f196.google.com with SMTP id y1so9448844oie.12
        for <linux-nfs@vger.kernel.org>; Sat, 26 Jan 2019 00:39:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gALillPbNkPldw2oG2g+16C930PT+GUt9ZlGR5t0fAU=;
        b=CBecMT+3ayq97Dp6s0uPiCpDjBSUZ3uX4+zgZVhe3OEmpf4YIdbuBBRxUel7yQzmY1
         OGzlqmMtir859Jwjnzw/TlkZ6/wPAoSFN2AWlFglcYKPQJSNIex/0VUTto86CnRaEWJi
         p1523+QUXkHTxoipUWvqL6zIyx6rOugpJcVy4ZPnsRQp3L+XNG+q79q0oX62zlgEm/fe
         puLFeM3m2BcSgqsiMIm9Q6+D9RMUxqrjRCMsk8SsmSAGkp0m92Qq7JZAHKbfgtWUov57
         eJRxdHaZwJP9rt2XQnfTZTi37eWBx3j9FR38yZ4RT2rtJVq3LiNMdvIbI5UNxUKRL1J3
         DF2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=gALillPbNkPldw2oG2g+16C930PT+GUt9ZlGR5t0fAU=;
        b=FhJw/AtGmnKuxEd4rg0b68EeNhKarLM7AcUwPAKVwnaYN3j4bZcpoT9K5GcosbCmje
         qnMEmIjBn9D7YVC46EQJrYFkVBrok2OaPM8WTfMHovYsD5S86P7qblXCnPBLQJnmzrGl
         0+QHFFhtSFkaFcgrKKfcMK8RM7tT2ZOlq6Y04jV2OBSp25ty7aevuVMU5/koO+gfJY7j
         XC0Ed50Arf+TJNYqVnxvnQF8/LpPao7FWBYr19RagmjHhn3IlJbQCA1MwmDDC7A9jRQs
         TWThAQ+7olugdl2W9DsHccptLx0CShswdiuvjuiRHa5IYbCJ66IINhfJy22YtHGA/fiY
         4B9Q==
X-Gm-Message-State: AHQUAuZqZ6nQ4RmYgE7g2DrL0mnQx+OqNz1ofcfh6ktTIOndnYWGjQE4
        Qq0rMuL/A5+C4YooDUhdOABONtPYQ+ey9tHIJpY=
X-Google-Smtp-Source: AHgI3Ialgus3cNN+SX9jJuYJovikKWac6CRIycMDOG+9j27wX78LAhyqnFgNtQV3ykfxY0kPt+DojN+O/+d5paPWPi8=
X-Received: by 2002:aca:100b:: with SMTP id 11mr491566oiq.303.1548491979381;
 Sat, 26 Jan 2019 00:39:39 -0800 (PST)
MIME-Version: 1.0
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
 <878t0uuzxv.fsf@notabene.neil.brown.name> <CAOiN93=bh8WrCD8gZ+En4EfzTv2iHMn5n4w5=rYJOr6RbUkCKQ@mail.gmail.com>
 <20190110203320.GE15492@fieldses.org>
In-Reply-To: <20190110203320.GE15492@fieldses.org>
From:   Ashish Sangwan <ashishsangwan2@gmail.com>
Date:   Sat, 26 Jan 2019 14:09:28 +0530
Message-ID: <CAOiN93npkvux_xfJsAs1jc7HeEnNU=1up+6UzHrCNJcY5YteDw@mail.gmail.com>
Subject: Re: Handling of duplicate inode numbers for the directories in the
 nfs v3 kernel client
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     neilb@suse.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 11, 2019 at 2:03 AM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Dec 13, 2018 at 09:17:31AM +0530, Ashish Sangwan wrote:
> > Thanks for the clarification!
> >
> > On Thu, 13 Dec 2018, 4:15 am NeilBrown <neilb@suse.com wrote:
> > >
> > > On Thu, Dec 13 2018, Ashish Sangwan wrote:
> > >
> > > > Hi,
> > > >
> > > > Our NFS filer can sometimes return same inode number for different directories.
> > >
> > > Why?
> > The NFS fileserver is handling file systems over different nodes at
> > the same time.
> > To the client however, we want to present with a single pseudo fsid
> > (sent as part of the getattr) so that submounts can be avoided.
>
> Out of curiosity, why do you want to avoid submounts?

Apologies for late reply. Didn't notice I have a new mail for this thread.
Some of the user space utils doesn't work well on mount points.
For example, "rm -rf" on the mount point doesn't work. (unlink fails with EBUSY)
GNU coreutils "mv" also doesn't work (rename fails with EBUSY)
(all-though even if sub-mounts are avoided, we give back EXDEV as part
of rename but that is internally handled by mv which performs
write/unlink in that case)
Every time user have to perform such operations, we have to tell them
to explicitly perform a umount first.
>
> --b.
