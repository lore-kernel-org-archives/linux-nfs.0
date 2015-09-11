Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33902 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbIKRGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 13:06:08 -0400
Received: by oiev17 with SMTP id v17so46227384oie.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 10:06:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150911162715.GA21393@infradead.org>
References: <1441659544.3163.4.camel@primarydata.com>
	<20150908115900.4182d55a@canb.auug.org.au>
	<20150908060136.GA6220@infradead.org>
	<20150911162715.GA21393@infradead.org>
Date: Fri, 11 Sep 2015 13:06:07 -0400
Message-ID: <CAHQdGtS3LqNxoqp-Zec+n_gtJRKFUz_fSH_S8HQeRSYGFtK9Xg@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>, Doug Ledford <dledford@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2015 at 12:27 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Sep 07, 2015 at 11:01:36PM -0700, Christoph Hellwig wrote:
>> On Tue, Sep 08, 2015 at 11:59:00AM +1000, Stephen Rothwell wrote:
>> > This contains about 12 commits new since Sept 1 and the last 6 are only
>> > appearing in linux-next today (though I did not do Friday and Monday's
>> > linux-next).  Not judging, just noting.
>>
>> And one of tese recent commits causes a regression for block layouts
>> in xfstests generic/075.  Still need to check which one.
>
> "NFSv4.1/pNFS: Don't request a minimal read layout beyond the end of file"
>
> is the culprit, posted to the list for the first time and committed on
> Aug 31.

That looks like it is tickling a server protocol bug.

The minimum length is just that; a minimum. If the server wants the
layout to be block aligned, then it is supposed to adjust the returned
offset + length values so that they cover the range described by the
offset+minimum length (see table 13 on
https://tools.ietf.org/html/rfc5661#page-540).
The server is only supposed to fail the LAYOUTGET request if it is
completely unable to meet those requirements. Furthermore, it is
supposed to return either NFS4ERR_BADLAYOUT or NFS4ERR_LAYOUTTRYLATER
(depending on what the value of the minimum layout was); as far as I
can see, the current code is returning NFS4ERR_LAYOUTUNAVAILABLE.

Cheers,
  Trond
