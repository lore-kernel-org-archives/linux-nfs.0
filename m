Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37952 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab3J1JxJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 05:53:09 -0400
Date: Mon, 28 Oct 2013 02:53:01 -0700
From: Hellwig Christoph <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Hellwig Christoph <hch@infradead.org>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Message-ID: <20131028095301.GA23614@infradead.org>
References: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
 <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
 <20131027165628.GA447@infradead.org>
 <95C57010-2A89-423C-8668-DF963ABF8BB6@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <95C57010-2A89-423C-8668-DF963ABF8BB6@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 27, 2013 at 06:07:46PM +0000, Myklebust, Trond wrote:
> The user xattrs are in principle harmless. What about "trusted.*"?

trusted ones are still fairly harmless and exist in most implementations
under a slightly different name.  They aren't quite as essential,
though.

The important point is to not carry over the system and security namespacs.
Those are a bad and Linux specific mistake to abuse the xattr interface for
all kinds of other interfaces.  This isn't something that should be carried
over to other standards.
