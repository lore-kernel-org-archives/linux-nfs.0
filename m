Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:41180 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905Ab2EVSlW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 14:41:22 -0400
Message-ID: <4FBBDDCF.4070803@parallels.com>
Date: Tue, 22 May 2012 22:41:19 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
References: <1337087550-9821-4-git-send-email-simo@redhat.com> <20120522124728.GB891@fieldses.org> <1337691607.16840.178.camel@willson.li.ssimo.org> <4FBB91EE.3010307@parallels.com> <1337692966.16840.181.camel@willson.li.ssimo.org> <4FBB9551.9010407@parallels.com> <20120522142035.GC891@fieldses.org> <4FBBA667.4090409@parallels.com> <20120522150748.GF891@fieldses.org> <4FBBAE81.9010708@parallels.com> <20120522181129.GB4697@fieldses.org>
In-Reply-To: <20120522181129.GB4697@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

22.05.2012 22:11, J. Bruce Fields написал:
> On Tue, May 22, 2012 at 07:19:29PM +0400, Stanislav Kinsbursky wrote:
>> Just a reminder: abstract (is it the right name?) UNIX sockets (with
>> '\0' as a first character in name) are containerized already.
>> If UNIX socket is the only way. then maybe this "abstract" socket can be used?
> Huh.  Reading the section on abstract addresses in unix(7)....  Maybe
> that would work.  I don't quite understand the namespace.  If we fix a
> name for gss-proxy to use, what's to prevent somebody else from binding
> to the same name and preventing us from using it?

Alien network namespace.
Abstract sockets address consist of two parts: name istelf and network 
namespace.
Have a look at unix_bind () - you'll see, that sockets with the same 
name but different network namespace are skipped.

>
> --b.

