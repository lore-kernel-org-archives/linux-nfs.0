Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279Ab1ILW1f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Sep 2011 18:27:35 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20110912222306.GB17483@fieldses.org>
References: <20110912222306.GB17483@fieldses.org> <25175.1315572498@redhat.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <26458.1315577016@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: dhowells@redhat.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        agruen@kernel.org, akpm@linux-foundation.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 00/26] New ACL format for better NFSv4 acl interoperability
Date: Mon, 12 Sep 2011 23:27:02 +0100
Message-ID: <8331.1315866422@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

J. Bruce Fields <bfields@fieldses.org> wrote:

> Probably the documentation belongs in man pages.  Which I think they've
> done, but alas the git repos (on kernel.org) aren't accesible right
> now....

There is also an in-kernel API that filesystems have to deal with if they want
to support richacls.  See the ext4 patches...  There should probably be one
document describing how to 'use' ACLs of all kinds from a filesystem internals
point of view somewhere under Documentation/filesystems/

David
