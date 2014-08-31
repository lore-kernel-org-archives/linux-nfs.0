Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:38437 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaHaAcJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Aug 2014 20:32:09 -0400
Received: by mail-qg0-f45.google.com with SMTP id e89so3813842qgf.18
        for <linux-nfs@vger.kernel.org>; Sat, 30 Aug 2014 17:32:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140830232755.GG7996@ZenIV.linux.org.uk>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
 <20140829205817.GB7996@ZenIV.linux.org.uk> <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
 <20140829230147.GD7996@ZenIV.linux.org.uk> <CAKVebiWBU3du650yeTMfaFuLr=WLUBc2RukFGyBF6Qgxd6zA8Q@mail.gmail.com>
 <20140830173638.GE7996@ZenIV.linux.org.uk> <20140830232755.GG7996@ZenIV.linux.org.uk>
From: Peng Tao <tao.peng@primarydata.com>
Date: Sun, 31 Aug 2014 08:31:47 +0800
Message-ID: <CAKVebiV8erTbK6ZA1g2X+xsKRBG2n61XBoqc04NvzSGTZRhTgw@mail.gmail.com>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 31, 2014 at 7:27 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>         Could you check if vfs.git#for-linus fixes that crap?
The related commits are the top two of vfs.git#for-linus, right? I
cherry-picked them to 3.14.15 and they fixed the bug instantly. Thank
you for the quick fix!

Cheers,
Tao
