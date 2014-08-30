Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:59540 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbaH3X14 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Aug 2014 19:27:56 -0400
Date: Sun, 31 Aug 2014 00:27:55 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
Message-ID: <20140830232755.GG7996@ZenIV.linux.org.uk>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
 <20140829205817.GB7996@ZenIV.linux.org.uk>
 <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
 <20140829230147.GD7996@ZenIV.linux.org.uk>
 <CAKVebiWBU3du650yeTMfaFuLr=WLUBc2RukFGyBF6Qgxd6zA8Q@mail.gmail.com>
 <20140830173638.GE7996@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140830173638.GE7996@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

	Could you check if vfs.git#for-linus fixes that crap?
