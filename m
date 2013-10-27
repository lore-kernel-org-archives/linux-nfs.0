Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:41970 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753331Ab3J0Mbt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 08:31:49 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
CC: Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Date: Sun, 27 Oct 2013 12:31:46 +0000
Message-ID: <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
References: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 26, 2013, at 10:01 AM, Matt W. Benjamin <matt@linuxbox.com> wrote:

> Hi,
> 
> Surely you don't need NFSv4 to standardize the the (empty?) set of system or magic attributes Linux
> should export?

The NFSv4 working group has no authority to do so. POSIX would be the right address.

> Besides, as you're well aware, most people who ask for xattrs are looking for an ability to associate
> arbitrary specific data, not a back door ioctl interface.  That's clearly what the NFSv4 named attributes as standardized were intended for.

No. I'm not aware of that.

> I'm well aware of other uses and plans that someone would want to standardize, but it seems
> irrelevant to the discussion.

It's very relevant to the discussion as it defines what namespace applications can expect to work.

Trond