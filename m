Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965208Ab3IEMeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 08:34:11 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <alpine.DEB.2.00.1309040923080.1073@cobra.newdream.net>
References: <alpine.DEB.2.00.1309040923080.1073@cobra.newdream.net> <alpine.DEB.2.00.1308212203320.1479@cobra.newdream.net> <cover.1375999914.git.milosz@adfin.com> <17341.1378309753@warthog.procyon.org.uk> <alpine.DEB.2.00.1309040851080.27503@cobra.newdream.net>
To: Sage Weil <sage@inktank.com>
Cc: dhowells@redhat.com, Milosz Tanski <milosz@adfin.com>,
        ceph-devel@vger.kernel.org, zheng.z.yan@intel.com,
        linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCHv4 0/5] ceph: persistent caching with fscache
Date: Thu, 05 Sep 2013 13:34:03 +0100
Message-ID: <18383.1378384443@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've pushed the non-Ceph bits of the bad-page fix to here:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache

and added a CIFS fix.

David
