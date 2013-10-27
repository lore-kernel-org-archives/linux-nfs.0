Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:13343 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab3J0Sl2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 14:41:28 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Hellwig Christoph <hch@infradead.org>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        "Dr Fields James Bruce" <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Date: Sun, 27 Oct 2013 18:41:25 +0000
Message-ID: <C586D6EC-47DF-4FAE-8BB3-7D0E7400B86F@netapp.com>
References: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
 <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
 <20131027165628.GA447@infradead.org>
 <95C57010-2A89-423C-8668-DF963ABF8BB6@netapp.com>
 <1382898655.899.122.camel@willson.li.ssimo.org>
In-Reply-To: <1382898655.899.122.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 27, 2013, at 2:30 PM, Simo Sorce <simo@redhat.com> wrote:

> On Sun, 2013-10-27 at 18:07 +0000, Myklebust, Trond wrote:
>> On Oct 27, 2013, at 12:56 PM, Christoph Hellwig <hch@infradead.org> wrote:
>> 
>>> On Sun, Oct 27, 2013 at 12:31:46PM +0000, Myklebust, Trond wrote:
>>>> The NFSv4 working group has no authority to do so. POSIX would be the right address.
>>> 
>>> The complete lack of clue, authority or even defined semantics didn't
>>> stop them from defining their ACL model.  User extended attributes are
>>> harmless compared to that, even if everyone has subtly different
>>> flavours.
>>> 
>> 
>> The user xattrs are in principle harmless. What about "trusted.*"?
>> 
>> BTW: caching any xattrs is a problem. There is no close-to-open model that you can use and neither is there locking. This is already causing a problem for labeled nfs...
> 
> You could start without caching them.
> 

I'm not going to start anything...

Trond