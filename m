Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55056 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755801Ab1DHJ4A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Apr 2011 05:56:00 -0400
Message-ID: <4D9EDC05.2080809@cn.fujitsu.com>
Date: Fri, 08 Apr 2011 17:57:25 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd41: make sure nfs server process OPEN with EXCLUSIVE4_1
 correcttly
References: <4D9C2CB2.7000101@cn.fujitsu.com> <20110407195005.GC11806@fieldses.org>
In-Reply-To: <20110407195005.GC11806@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields :
> On Wed, Apr 06, 2011 at 05:04:50PM +0800, Mi Jinlong wrote:
>> At the recent kernel(2.6.39-rc1),
> 
> (But this is not a regression, right?  This has been a problem all
> along.)

  Yes, I think it's just a problem.

> 
>> NFS server can't process OPEN with EXCLUSIVE4_1,
>> because NFS server call nfsd_create_v3 to create file instead implement a separate
>> one. But nfsd_create_v3 can't process createmode is EXCLUSIVE4_1.
> 
> Is our handling of the attributes correct in this case?  (See e.g. the
> op_bmval[1] assignment a few lines down.)

  There is no problem of the p_bmval[1] assignment a few lines down.
  According to rfc5661 18.16.3, EXCLUSIVE4_1 supports the setting of
  attributes at file creation, we don't need to set p_bmval[1] assignment
  as EXCLUSIVE.

  I think we should have a fix at nfsd_create_v3(), not at do_open_lookup().
  Please ignore the old patch, a new one is as following.

--
thanks,
Mi Jinlong

=============================================================================
