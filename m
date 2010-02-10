From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: Failure to fallback to nfsd-v3 (?)
Date: Wed, 10 Feb 2010 11:17:17 +0900
Message-ID: <877hqln8b6.fsf@devron.myhome.or.jp>
References: <87pr4h67rf.fsf@devron.myhome.or.jp>
	<20100207041016.GA16865@fieldses.org>
	<8763695u96.fsf@devron.myhome.or.jp>
	<20100208183343.GC10665@fieldses.org>
	<20100209165547.GB29091@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:35983 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122Ab0BJCR0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2010 21:17:26 -0500
In-Reply-To: <20100209165547.GB29091@fieldses.org> (J. Bruce Fields's message
	of "Tue, 9 Feb 2010 11:55:47 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

>> > > It's expected.  I'd recommend turning off nfsv4 on the server (add "-N4"
>> > > to the rpc.nfsd commandline) for now.
>> > 
>> > This looks like the silent user visible change. So, it would be better
>> > to add more comment at least in changelog.
>> > 
>> > Well, anyway, thanks. (BTW, I assumed rpc.nfsd is typo of rpc.mountd)
>> 
>> No, the -N4 tells rpc.mountd to turn off NFSv4 support before starting
>
> (Hah!--trying to correct you, I got it wrong myself--I really did mean
> rpc.*nfsd*, not rpc.mountd.)

Oh, I was reading very old man page. Thanks for correcting.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
