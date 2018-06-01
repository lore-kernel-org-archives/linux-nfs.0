Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:38838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751346AbeFANii (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 09:38:38 -0400
From: David Howells <dhowells@redhat.com>
To: steved@redhat.com, Anna.Schumaker@Netapp.com, jumitche@redhat.com
cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        viro@ZenIV.linux.org.uk
Subject: NFS mount-api patches
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 01 Jun 2018 14:38:36 +0100
Message-ID: <22188.1527860316@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve, Anna,

Al pulled my mount API patches into his tree and fixed them up.  I've ported
my NFS mount-API patches on top of them, so they apply and build (at least
with my settings).  Do you have time now to have a poke at them to get them to
work?  (I'm a bit tight for time this afternoon, so I don't have time to test
them till next week)

https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=nfs-mount-api

David
