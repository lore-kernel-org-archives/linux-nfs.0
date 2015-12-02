Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:56803 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756648AbbLBH2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 02:28:00 -0500
Date: Wed, 2 Dec 2015 08:27:57 +0100
From: Christoph Hellwig <hch@lst.de>
To: Steve French <smfrench@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Peng Tao <tao.peng@primarydata.com>,
        Jeffrey Layton <jeff.layton@primarydata.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>
Subject: Re: vfs: move btrfs clone ioctls to common code
Message-ID: <20151202072757.GB15839@lst.de>
References: <1448563859-21922-1-git-send-email-hch@lst.de> <CAH2r5muW6=v6tx3BwXSYMgn7EZgzVANniebsxfwpdq9Y=0VcuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5muW6=v6tx3BwXSYMgn7EZgzVANniebsxfwpdq9Y=0VcuA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

we have two APIs in Linux:

 - the copy_file_range syscall which just is a "do a copy by any means"
 - the btrfs clone ioctls which have stricter semantics that very much
   expect a reflink-like operation

I plan to also wire up copy_file_range to try the clone_file_range method
first if available to make life easier for file systems, but as there isn't
any test coverage for that I don't dare to actually submit it yet.  I'll
send a compile tested only RFC for it when resending this series.
