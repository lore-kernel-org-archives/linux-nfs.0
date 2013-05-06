Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tundra.namei.org ([65.99.196.166]:40195 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753701Ab3EFIPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 04:15:01 -0400
Date: Mon, 6 May 2013 18:19:10 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: Ric Wheeler <rwheeler@redhat.com>
cc: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>, Jack Rieden <jrieden@redhat.com>
Subject: Re: [PATCH 00/17] lnfs: linux-3.9 release
In-Reply-To: <51848BE0.2080901@redhat.com>
Message-ID: <alpine.LRH.2.02.1305061817290.28613@tundra.namei.org>
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com> <51848BE0.2080901@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 4 May 2013, Ric Wheeler wrote:

> It would be great to see this patch series land in time for 3.10 - seems like
> a major feature that has had been held in development for years and it does
> have a very interested user base waiting for this to land.
> 
> Are there any existing roadblocks to having this make it this merge window?


Not that I'm aware of, but I feel they should all go in via the same tree 
(an NFS one), rather than being split across subsystems, which has been 
suggested off list.  It's better to keep them all in one place where they 
can be tested and maintained together.


- James
-- 
James Morris
<jmorris@namei.org>
