Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58088 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641Ab1IVMBi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 08:01:38 -0400
Date: Thu, 22 Sep 2011 08:01:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 00/26]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20110922120129.GC28182@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <878vpi73oc.fsf@skywalker.in.ibm.com>
 <20110921194531.GB23634@fieldses.org>
 <87vcsl5eiq.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87vcsl5eiq.fsf@skywalker.in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 22, 2011 at 11:01:41AM +0530, Aneesh Kumar K.V wrote:
> richacl-fullset branch should have the full patchset including nfsd
> changes. The changes are based on an older kernel version.

Got it, thanks!

> Currently i
> am planning to focus on the local file system and VFS changes so that we
> can get that merged upstream.

Understood.

--b.
