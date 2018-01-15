Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:42414 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755637AbeAORl4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jan 2018 12:41:56 -0500
Date: Mon, 15 Jan 2018 18:41:56 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Max Kellermann <mk@cm4all.com>
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        max.kellermann@gmail.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] dFrom: Max Kellermann <mk@cm4all.com>
Message-ID: <20180115174156.GB22809@kroah.com>
References: <151603744662.29035.4910161264124875658.stgit@rabbit.intern.cm-ag>
 <151603745169.29035.6866708909114015882.stgit@rabbit.intern.cm-ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <151603745169.29035.6866708909114015882.stgit@rabbit.intern.cm-ag>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 15, 2018 at 06:30:51PM +0100, Max Kellermann wrote:
> nfs/super: set MS_POSIXACL only if ACL support is enabled
> 
> The code comment says "We will [apply the umask] ourselves", but that
> happens in posix_acl_create() only if the kernel has POSIX ACL
> support.  Without it, posix_acl_create() is a is an empty dummy
> function.

<snip>

Your subject line is a bit odd :(

