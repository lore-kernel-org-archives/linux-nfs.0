Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38396 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751632AbdFHNe3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 09:34:29 -0400
Date: Thu, 8 Jun 2017 09:34:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: devzero@web.de
Cc: linux-nfs@vger.kernel.org, pf@artcom-gmbh.de, rnews@altium.nl,
        jlayton@redhat.com
Subject: Re: How to avoid rebooting Linux NFS-client when NFS-server is not
 available?
Message-ID: <20170608133423.GG26995@fieldses.org>
References: <trinity-f2c19596-3afe-4a3f-ad07-78e6cfda9cb5-1496911790012@3capp-webde-bap34>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <trinity-f2c19596-3afe-4a3f-ad07-78e6cfda9cb5-1496911790012@3capp-webde-bap34>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 08, 2017 at 10:49:50AM +0200, devzero@web.de wrote:
> Any hint on how to circumvent rebooting to remount the nfs share or proactively avoid stale NFS mounts would be very appreciated. (disabling NFS by module unload/load is no option, as our XEN servers do have other NFS mounts for shared storage)

Neil had some recent posts that might be relevant:

	http://marc.info/?l=util-linux-ng&m=149662998931157&w=2

Ripping out the storage from underneath your applications is a pretty
drastic step and may lose data, so NFS hasn't traditionally tried very
hard to make it easy.  But it may be possible at this point if you kill
-9 all the users and umount carefully.

> I`m not sure if linux-nfs ML will allow anonymous posts (probably
> not), so maybe someone subscribed be so kind to reply with list cc´ed.
> I`d like to avoid subscribing to a list because of a single post...

That's fine.

--b.
