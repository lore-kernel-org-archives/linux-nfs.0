Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51696 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507Ab3J1Ach convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 20:32:37 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: Simo Sorce <simo@redhat.com>, Hellwig Christoph <hch@infradead.org>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Date: Mon, 28 Oct 2013 00:32:35 +0000
Message-ID: <B1BC8908-0495-4D73-96C5-9E3E1AA0D883@netapp.com>
References: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
 <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
 <20131027165628.GA447@infradead.org>
 <95C57010-2A89-423C-8668-DF963ABF8BB6@netapp.com>
 <1382898655.899.122.camel@willson.li.ssimo.org>
 <C586D6EC-47DF-4FAE-8BB3-7D0E7400B86F@netapp.com>
 <1382912457.6932.21.camel@heisenberg.scientia.net>
In-Reply-To: <1382912457.6932.21.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 27, 2013, at 6:20 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> On Sun, 2013-10-27 at 18:41 +0000, Myklebust, Trond wrote:
>> I'm not going to start anything...
> So that's basically a: "XATTRs in NFS - never"?! :(

Your case for adding the feature seems to be "I have a couple of programs that use xattrs, so NFS should provide it.".

Well, that means at a minimum going to the IETF (possibly also POSIX) to convince them that the feature is worth adding, helping design the protocol to do so, and achieving consensus in a NFSv4.x spec, then doing the work designing and coding up a Linux implementation. Who is volunteering to do all that?

My statement above was that I'm not volunteering to do all this. You haven't convinced me that your programs cannot be modified to use other more portable solutions. You're not even generating the checksums when creating the data, so there is already an existing window during which corruption can occur.

Trond