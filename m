From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Tue, 14 Oct 2008 13:43:39 -0400
Message-ID: <20081014174339.GD17899@fieldses.org>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net> <20081004213625.GA3709@fieldses.org> <18674.34066.316972.695627@notabene.brown> <CCAC2CA2-FEAE-4383-9F7D-F63BBF0E701E@oracle.com> <20081013174613.GH28864@fieldses.org> <668D398B-7814-4831-ABC2-8F8CF1FBE4D0@oracle.com> <18676.27741.921124.742371@notabene.brown> <5ACEC030-6463-445B-9B1B-9220EB3566C5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51942 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbYJNRno (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Oct 2008 13:43:44 -0400
In-Reply-To: <5ACEC030-6463-445B-9B1B-9220EB3566C5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 14, 2008 at 11:52:52AM -0400, Chuck Lever wrote:
> On Oct 14, 2008, at Oct 14, 2008, 5:54 AM, Neil Brown wrote:
>> I agree that the man page should reflect reality.
>
> Several people have said that, but no-one has suggested what specific  
> parts of the man page are problematic.

Look at, e.g., the text for "-T":
	Disable rpc.nfsd from accepting TCP connections from clients.

It should probably say lockd is unaffected.  (If that's what we want.)

Also the wording is a little imprecise, since rpc.nfsd itself doesn't
accept network connections.

--b.
