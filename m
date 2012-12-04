Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35405 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295Ab2LDOUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2012 09:20:43 -0500
Received: by mail-lb0-f174.google.com with SMTP id gi11so3410329lbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 04 Dec 2012 06:20:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121204111006.23758.22102.stgit@localhost.localdomain>
References: <20121204111006.23758.22102.stgit@localhost.localdomain>
Date: Tue, 4 Dec 2012 09:20:41 -0500
Message-ID: <CACLa4psccEppztVNBAvXBFwvMBaOfsJWbrw7u39x1iT0D6o8sA@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: connect to UNIX sockets synchronously
From: Eric Paris <eparis@parisplace.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bruce Fields <bfields@fieldses.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        devel@openvz.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 4, 2012 at 6:10 AM, Stanislav Kinsbursky
<skinsbursky@parallels.com> wrote:

> But there should be noted, that such implementation introduces limitation
> (Trond's quote):
> "That approach can fall afoul of the selinux restrictions on the process
> context. Processes that are allowed to write data, may not be allowed to
> create sockets or call connect(). That is the main reason for doing it
> in the rpciod context, which is a clean kernel process context."

So you tested this and Trond was wrong?  This work just fine even on
an SELinux box?  Or it does break tons and tons of people's computers?

-Eric
