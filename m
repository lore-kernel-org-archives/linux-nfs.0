Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45233 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036Ab1LYEaJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Dec 2011 23:30:09 -0500
Message-ID: <4EF6A6CA.1020606@tonian.com>
Date: Sun, 25 Dec 2011 06:30:02 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: lsf-pc@lists.linux-foundation.org
CC: linux-fsdevel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [LSF/MM TOPIC] [ATTEND] linux-pnfs server implementations
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the client side of pnfs is in the mainline kernel
I believe it is time to consider the inclusion of the server side.

I propose the following agenda for discussion
(order may change with no advance notice :)

* What's currently available in git://linux-nfs.org/~halevy/linux-pnfs.git
  - What are the sub-projects
  - How they relate to each other

* High-level design of the implementation

* Summary of generic changes in nfsd

* For each of the different sub-projects, briefly present:
  - What does it do
  - Benefits and Potential
  - Limitations
  - Status
  - To-do

* Prerequisites for inclusion

* Discussion

Benny
