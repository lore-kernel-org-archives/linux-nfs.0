Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f41.google.com ([209.85.219.41]:39730 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbaBFSTU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 13:19:20 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so2819038oag.0
        for <linux-nfs@vger.kernel.org>; Thu, 06 Feb 2014 10:19:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPCnwUeUEznrKvJ-upUV_VyaKKhZcKpZbLFeC08YMMQycWK-vg@mail.gmail.com>
References: <CAPCnwUeUEznrKvJ-upUV_VyaKKhZcKpZbLFeC08YMMQycWK-vg@mail.gmail.com>
Date: Thu, 6 Feb 2014 13:19:19 -0500
Message-ID: <CAPCnwUeobfXKGB9Q-nyYNDZa1L9iTwoKZm9bBH2ghUkqembCeA@mail.gmail.com>
Subject: Re: Windows AD, Users with too many groups
From: Norman Elton <normelton@gmail.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just a follow-up to my previous post. In debugging rpc.gssd on the
client, here's where things are dying:

creating tcp client for server filertest.safety.net.wm.edu
creating context with server nfs@filertest.safety.net.wm.edu
WARNING: Failed to create krb5 context for user with uid 30487 for
server filertest.safety.net.wm.edu

But other users seem fine. I still think it's something to do with
excessive group membership.

Any suggestions are appreciated, thanks!

Norman Elton
College of William & Mary

On Mon, Feb 3, 2014 at 4:13 PM, Norman Elton <normelton@gmail.com> wrote:
> I've read stories about users having too many group memberships. We
> seem to experience similar symptoms, though the usual tricks don't
> seem to work.
>
> In our case, there is a RHEL6 NFS server feeding multiple RHEL6 NFS
> clients. This is all NFSv4 with Kerberos. Most users can login fine,
> but domain admins get a "permission denied" when accessing their
> NFS-mounted home directory. The most notable commonality is their high
> number of group memberships.
>
> I've tried inflating my group count to greater than 16, my account
> continues to work fine.
>
> We've tried adding "--manage-gids" to rpc.mountd, no luck. Although
> it's unclear whether this really does anything in a kerberized
> environment.
>
> Any other suggestions? Other debugging tricks?
>
> Thanks
>
> Norman Elton
