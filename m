Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880Ab1AUPkq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jan 2011 10:40:46 -0500
From: David Howells <dhowells@redhat.com>
To: lsf-pc@lists.linuxfoundation.org
cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [LSF/MM TOPIC] Per-directory filesystem configuration
Date: Fri, 21 Jan 2011 15:40:25 +0000
Message-ID: <3663.1295624425@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


I'd like to propose a discussion topic for the LSF: how best to implement a
means of configuring filesystems at the directory level?  For instance, with
NFS, CIFS and AFS it is desirable to be able to adjust caching parameters on a
per-subtree basis (a directory and everything under it), but it is not
necessarily possible to store this information on the server, nor is it
necessarily desirable to use such information retrieved from the server on
every client.

Furthermore, this facility could control more than just caching details.  With
the ability of filesystems to do in-kernel automounting, this could be used to
give instructions to the filesystem in a way that's not currently possible.

David
