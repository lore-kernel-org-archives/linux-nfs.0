Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35424 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab3J0Q4g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 12:56:36 -0400
Date: Sun, 27 Oct 2013 09:56:29 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Matt W. Benjamin" <matt@linuxbox.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Message-ID: <20131027165628.GA447@infradead.org>
References: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
 <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 27, 2013 at 12:31:46PM +0000, Myklebust, Trond wrote:
> The NFSv4 working group has no authority to do so. POSIX would be the right address.

The complete lack of clue, authority or even defined semantics didn't
stop them from defining their ACL model.  User extended attributes are
harmless compared to that, even if everyone has subtly different
flavours.

