Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:48627 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab2LEHtD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2012 02:49:03 -0500
Message-ID: <50BEFC52.8030902@parallels.com>
Date: Wed, 5 Dec 2012 11:48:34 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Eric Paris <eparis@parisplace.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bruce Fields <bfields@fieldses.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: connect to UNIX sockets synchronously
References: <20121204111006.23758.22102.stgit@localhost.localdomain> <CACLa4psccEppztVNBAvXBFwvMBaOfsJWbrw7u39x1iT0D6o8sA@mail.gmail.com>
In-Reply-To: <CACLa4psccEppztVNBAvXBFwvMBaOfsJWbrw7u39x1iT0D6o8sA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

04.12.2012 18:20, Eric Paris пишет:
> On Tue, Dec 4, 2012 at 6:10 AM, Stanislav Kinsbursky
> <skinsbursky@parallels.com> wrote:
>
>> But there should be noted, that such implementation introduces limitation
>> (Trond's quote):
>> "That approach can fall afoul of the selinux restrictions on the process
>> context. Processes that are allowed to write data, may not be allowed to
>> create sockets or call connect(). That is the main reason for doing it
>> in the rpciod context, which is a clean kernel process context."
>
> So you tested this and Trond was wrong?  This work just fine even on
> an SELinux box?  Or it does break tons and tons of people's computers?
>
> -Eric
>

You can read discussion here:
https://patchwork.kernel.org/patch/1565111/

We use AF_LOCAL transports only for portmapper calls.
So, we decided (or at least I understood that so) to make such connections
from process context - i.e. synchronously.

-- 
Best regards,
Stanislav Kinsbursky
