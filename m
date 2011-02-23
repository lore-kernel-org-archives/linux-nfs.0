Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37260 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932065Ab1BWQnO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 11:43:14 -0500
In-Reply-To: <1298445725.20733.2.camel@perseus>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
 <1295420817.3076.24.camel@perseus> <1297779902.13007.86.camel@perseus> <1298445725.20733.2.camel@perseus>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 23 Feb 2011 08:37:17 -0800
Message-ID: <AANLkTim_JWgT_kK506Lu8-vNC0rkBhCvO+7-CFb66nNP@mail.gmail.com>
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
To: Ian Kent <raven@themaw.net>
Cc: Nick Piggin <npiggin@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 22, 2011 at 11:22 PM, Ian Kent <raven@themaw.net> wrote:
>
> Nick, what stops a dentry from going away during the rcu-walk?

Dentries (and now inodes) are all RCU-free'd. So the dentry might "go
away", but it wouldn't actually be physically free'd, and you can
still access it.

                            Linus
