From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 17/19] NFSD: Stricter buffer size checking in
	fs/nfsd/nfsctl.c
Date: Tue, 28 Apr 2009 17:30:57 -0400
Message-ID: <20090428213057.GK23924@fieldses.org>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233325.17283.71127.stgit@ingres.1015granger.net> <20090428163130.GL17891@fieldses.org> <933CF5D0-337D-46CF-81E8-13F617BF0B2F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58212 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758810AbZD1Va5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 17:30:57 -0400
In-Reply-To: <933CF5D0-337D-46CF-81E8-13F617BF0B2F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2009 at 12:36:38PM -0400, Chuck Lever wrote:
> On Apr 28, 2009, at 12:31 PM, J. Bruce Fields wrote:
>> On Thu, Apr 23, 2009 at 07:33:25PM -0400, Chuck Lever wrote:
>>> Clean up: For consistency, handle output buffer size checking in a
>>> other nfsctl functions the same way it's done for write_versions().
>>
>> These all look fine to me, thanks.  Let me know when you want them
>> applied.
>
> Just to confirm that 1/19 looks OK to you too... I think you can apply 1 
> - 17 now.

OK, applied for 2.6.31.

--b.
