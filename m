Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42521 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935Ab0H2KuG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Aug 2010 06:50:06 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1OpfSe-0007vr-Ts
	for linux-nfs@vger.kernel.org; Sun, 29 Aug 2010 12:50:04 +0200
Received: from tebokkel.com ([213.84.165.19])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 29 Aug 2010 12:50:04 +0200
Received: from paul+gmane by tebokkel.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 29 Aug 2010 12:50:04 +0200
To: linux-nfs@vger.kernel.org
From: Paul te Bokkel <paul+gmane@tebokkel.com>
Subject: Kerberos impersonate for server as NFS-client? =?utf-8?b?KH4=?= homes on kerberized NFS)
Date: Sun, 29 Aug 2010 10:45:32 +0000 (UTC)
Message-ID: <loom.20100826T112814-591@post.gmane.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I am looking for a solution to use an Apache-box as client to a GFS2-
cluster, using kerberized NFS3. My problem is similar to using home-
directories in this situation, but with home-dirs, there's normally
an interactive user with a valid ticket.
With an Apache-server, serving data from 'home-directories' (ie,
user-owned data, accessed on the GFS2-cluster by the owners) it
wouldn't be a problem to assume the UID from a user on a mount with
AUTH_SYS. With AUTH_GSS however, the Apache proces would need to be
kerberized (ie, use the impersonation calls).

Correct?


AFAIK Apache has not been kerberized for this purpose and it's not
possible with Linux to generally authorize impersonation on a single
mount when using AUTH_GSS?

TIA,

Paul te Bokkel
paul@tebokkel.com
Apeldoorn, The Netherlands



