Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:1800 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751849Ab3JZOB4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Oct 2013 10:01:56 -0400
Date: Sat, 26 Oct 2013 10:01:41 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Message-ID: <312486415.16.1382796101374.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <432349691.14.1382795633967.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: XATTRs in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Surely you don't need NFSv4 to standardize the the (empty?) set of system or magic attributes Linux
should export?

Besides, as you're well aware, most people who ask for xattrs are looking for an ability to associate
arbitrary specific data, not a back door ioctl interface.  That's clearly what the NFSv4 named attributes as standardized were intended for.

I'm well aware of other uses and plans that someone would want to standardize, but it seems
irrelevant to the discussion.

Matt


----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> 
> Standardise those xattrs, and we can export them specifically as part
> of the NFSv4 spec.
> 

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
