Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hapkido.dreamhost.com ([66.33.216.122]:50708 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135Ab2GXUCE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2012 16:02:04 -0400
Received: from homiemail-a86.g.dreamhost.com (caiajhbdccac.dreamhost.com [208.97.132.202])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 99B23167F
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 13:02:03 -0700 (PDT)
Received: from homiemail-a86.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a86.g.dreamhost.com (Postfix) with ESMTP id 7310E36006B
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 13:00:58 -0700 (PDT)
Received: from mail-gg0-f174.google.com (mail-gg0-f174.google.com [209.85.161.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a86.g.dreamhost.com (Postfix) with ESMTPSA id 453EA36006A
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 13:00:58 -0700 (PDT)
Received: by gglu4 with SMTP id u4so7114012ggl.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 13:00:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120724193348.GA4977@netapp.com>
References: <20120724193348.GA4977@netapp.com>
Date: Tue, 24 Jul 2012 15:00:57 -0500
Message-ID: <CAK3OfOji009CP88tDNOp-nvdPBkvp0oKfJUqhO_TYuZktwhUCg@mail.gmail.com>
Subject: Re: [nfsv4] Constructing a NFSv4 ACL from POSIX mode bits
From: Nico Williams <nico@cryptonector.com>
To: "Haynes, Tom" <thomas@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, nfsv4@ietf.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 2:33 PM, Haynes, Tom <thomas@netapp.com> wrote:
> Bruce,
>
> In looking at http://tools.ietf.org/html/draft-ietf-nfsv4-acl-mapping-05, it
> states that when mapping the write bit, only for the owner do we set
> ACE4_WRITE_ACL.
>
> Back in version 00, it is open as to whether we can also set it for the
> group and other if they have the write bit set.
>
> I looked back at the NFSv4 WG aliases and I see some discussion from Lisa
> on how Solaris only ever sets it for the owner due to POSIX restrictions
> via chmod(). So, now I know how another server does it.

This has changed.  I wrote this up here:

http://cryptonector.com/2011/11/zfs-aclchmod-interactions-in-solaris-11/

IIRC all ACEs for anything other than OWNER@ (or a user of the same
name/ID) contribute to the group bits of the mode, the EVERYONE@ entry
contributes to the world bits of the mode, and the OWNER@ and/or user
ACEs for the owner name/ID contribute to the owner bits of the mode.

The new scheme is really much simpler and more natural than everything
else tried before.

Nico
--
