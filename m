Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:47116 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbaBCVNL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 16:13:11 -0500
Received: by mail-ob0-f174.google.com with SMTP id uy5so8401445obc.5
        for <linux-nfs@vger.kernel.org>; Mon, 03 Feb 2014 13:13:11 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 3 Feb 2014 16:13:11 -0500
Message-ID: <CAPCnwUeUEznrKvJ-upUV_VyaKKhZcKpZbLFeC08YMMQycWK-vg@mail.gmail.com>
Subject: Windows AD, Users with too many groups
From: Norman Elton <normelton@gmail.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've read stories about users having too many group memberships. We
seem to experience similar symptoms, though the usual tricks don't
seem to work.

In our case, there is a RHEL6 NFS server feeding multiple RHEL6 NFS
clients. This is all NFSv4 with Kerberos. Most users can login fine,
but domain admins get a "permission denied" when accessing their
NFS-mounted home directory. The most notable commonality is their high
number of group memberships.

I've tried inflating my group count to greater than 16, my account
continues to work fine.

We've tried adding "--manage-gids" to rpc.mountd, no luck. Although
it's unclear whether this really does anything in a kerberized
environment.

Any other suggestions? Other debugging tricks?

Thanks

Norman Elton
