Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933643Ab1IIMig (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 08:38:36 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1315243548-18664-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
        akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 22/26] vfs: Cache richacl in struct inode
Date: Fri, 09 Sep 2011 13:37:45 +0100
Message-ID: <24985.1315571865@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Cache richacls in struct inode so that this doesn't have to be done
> individually in each filesystem.

Since many ACLs in a filesystem are going to be identical, can you have a
global hash table and share them?

David
