Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21540 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752030Ab3J0SHs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 14:07:48 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Hellwig Christoph <hch@infradead.org>
CC: "Matt W. Benjamin" <matt@linuxbox.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Date: Sun, 27 Oct 2013 18:07:46 +0000
Message-ID: <95C57010-2A89-423C-8668-DF963ABF8BB6@netapp.com>
References: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
 <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
 <20131027165628.GA447@infradead.org>
In-Reply-To: <20131027165628.GA447@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 27, 2013, at 12:56 PM, Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Oct 27, 2013 at 12:31:46PM +0000, Myklebust, Trond wrote:
>> The NFSv4 working group has no authority to do so. POSIX would be the right address.
> 
> The complete lack of clue, authority or even defined semantics didn't
> stop them from defining their ACL model.  User extended attributes are
> harmless compared to that, even if everyone has subtly different
> flavours.
> 

The user xattrs are in principle harmless. What about "trusted.*"?

BTW: caching any xattrs is a problem. There is no close-to-open model that you can use and neither is there locking. This is already causing a problem for labeled nfs...

Trond