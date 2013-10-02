Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f43.google.com ([209.85.160.43]:60822 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab3JBBZG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 21:25:06 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so166437pbc.2
        for <linux-nfs@vger.kernel.org>; Tue, 01 Oct 2013 18:25:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131001143400.GI26382@fieldses.org>
References: <CACFbnrwWJz8her6a4PRn-a0sTF2ci2VY7xOdgRS3zhFpYfxfug@mail.gmail.com>
 <20131001143400.GI26382@fieldses.org>
From: Marc Meledandri <m.meledandri@gmail.com>
Date: Tue, 1 Oct 2013 21:24:34 -0400
Message-ID: <CACFbnrxWCTnudK5GJK0=xpiE7xym=Jm4apMSbBHTHF-oavJP5g@mail.gmail.com>
Subject: Re: Issues with a rather unusual configured NFS server
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 1, 2013 at 10:34 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Sep 28, 2013 at 11:37:40AM -0400, Marc Meledandri wrote:
>> I was pointed at this thread by the linux-ext4 folks as relevant to my
>> issue on kernels in
>> the 3.10.x series. I see this commit was tagged for 3.12-rc2 on git,
>> and wondering if it will be
>> rebased for previous kernels? Maybe my issue (oops at shutdown) is
>> caused by something
>> else entirely? Thanks!
>
> That patch probably should have been cc'd to stable for kernels since
> 3.10....
>
> Do you have a reproduceable test case?  Would it be possible for you to
> confirm that this fixes your problem if applied on top of 3.10.x?
>
> --b.
>

Thanks for replying. Regarding confirmation, the patch does not apply
cleanly to 3.10.x kernels, but needs to be backported/rebased. I began
that process, as it's a small patch, but didn't want to step on, or
conflict with other changes that hadn't been merged yet from the
latest nfs codebase if such changes are forthcoming.

Regarding STR, I was seeing this on vanilla kernels 3.10.10 and
3.10.11 on shutdown (hangs with oops), and didn't pin down the exact
conditions. I have the simplest of nfs setups with a single
export/mount point and single client. I've recently built 3.10.13 with
no patches and will try to reproduce the oops. I think I need to leave
a client connected during shutdown.

Will follow up with more info...
