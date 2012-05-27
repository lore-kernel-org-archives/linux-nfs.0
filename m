Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:32390 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab2E0Uag convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 May 2012 16:30:36 -0400
Subject: Re: [PATCH] NFSD: TEST_STATEID should not return NFS4ERR_STALE_STATEID
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <62C4F65F-B822-4B00-B7AC-185EF14E39D8@oracle.com>
Date: Sun, 27 May 2012 16:30:24 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bryan Schumaker <bjschuma@netapp.com>
Message-Id: <B7E9175E-01AF-400D-9490-3E82F74478D5@oracle.com>
References: <20120524192932.8296.44698.stgit@lebasque.1015granger.net> <20120525134636.GA28842@fieldses.org> <62C4F65F-B822-4B00-B7AC-185EF14E39D8@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On May 25, 2012, at 7:30 PM, Chuck Lever wrote:

> On May 25, 2012, at 9:46 AM, J. Bruce Fields wrote:
> 
>> If you think it's worth checking for those buggy client cases, we could
>> instaed check that stateid->si_opaque.so_clid and cl->clientid agree.
>> That'd cover the special-stateid checks too.
> 
> That's interesting.  I can redrive this patch with this change.

Doesn't a positive find_stateid(cl, stateid) result guarantee that so_clid and clientid are the same?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




