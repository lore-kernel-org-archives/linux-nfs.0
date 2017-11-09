Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:35692 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750726AbdKITnB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 14:43:01 -0500
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <8fc5311b-fc56-1c19-8f63-0c509d3dd4ad@gentoo.org>
 <20171109193859.GC21978@ZenIV.linux.org.uk>
From: Patrick McLean <chutzpah@gentoo.org>
Message-ID: <a65e7692-3be2-38ce-9941-f4efbde0e20c@gentoo.org>
Date: Thu, 9 Nov 2017 11:42:58 -0800
MIME-Version: 1.0
In-Reply-To: <20171109193859.GC21978@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 2017-11-09 11:38 AM, Al Viro wrote:
> On Thu, Nov 09, 2017 at 11:34:19AM -0800, Patrick McLean wrote:
> 
>>> In particular, there are *no* nfsd changes in that 4.13.8..4.13.11
>>> range. There is a bunch of xfs changes, though. What's the underlying
>>> filesystem that you are exporting?
>>
>> It's an ext4 filesystem.
> 
> Had there been toolchain changes around the same period?
> 
No changes, both the working and broken kernels were built with
distro-provided gcc 5.4.0 and binutils 2.28.1.
