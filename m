Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:58702 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbcFDQM1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jun 2016 12:12:27 -0400
Subject: Re: Dcache oops
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20160604005611.GA14480@ZenIV.linux.org.uk>
Date: Sat, 4 Jun 2016 12:12:14 -0400
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Message-Id: <DF4A1130-84CD-4083-92B4-6DEA2D633753@linuxhacker.ru>
References: <74306F63-DBDF-4DED-85D2-5C3FB21B8A1E@linuxhacker.ru> <20160603182203.GR14480@ZenIV.linux.org.uk> <4285E00F-7228-485C-AD32-97552ED746F2@linuxhacker.ru> <20160603200759.GS14480@ZenIV.linux.org.uk> <CA+55aFznPit97evuwZHdCG55=N0QbkFSST2ydKxvExQTR-YXTg@mail.gmail.com> <20160603212652.GT14480@ZenIV.linux.org.uk> <CA+55aFyYkbXqoJ3PqfrnxWDEXJM_BH6Q_OdKf+UVJYEUF4gdQA@mail.gmail.com> <20160603222355.GW14480@ZenIV.linux.org.uk> <20160603223700.GY14480@ZenIV.linux.org.uk> <DA67EEEA-D769-4D0F-9C20-6145F2B0808F@linuxhacker.ru> <20160604005611.GA14480@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2016, at 8:56 PM, Al Viro wrote:

> On Fri, Jun 03, 2016 at 07:58:37PM -0400, Oleg Drokin wrote:
> 
>>> EOPENSTALE, that is...  Oleg, could you check if the following works?
>> 
>> Yes, this one lasted for an hour with no crashing, so it must be good.
>> Thanks.
>> (note, I am not equipped to verify correctness of NFS operations, though).
> 
> I suspect that Jeff Layton might have relevant regression tests.  Incidentally,
> we really need a consolidated regression testsuite, including the tests you'd
> been running.  Right now there's some stuff in xfstests, LTP and cthon; if
> anything, this mess shows just why we need all of that and then some in
> a single place.  Lustre stuff has caught a 3 years old NFS bug (missing
> d_drop() in nfs_atomic_open()) and a year-old bug in handling of EOPENSTALE
> retries on the last component of a trailing non-embedded symlink.  Neither
> is hard to trigger; it's just that relevant tests hadn't been run on NFS,
> period.

BTW, the nets also have brought in another use after free in nfs4 state
tracking code (this is the one I was trying to hunt down from the start).
I'll submit a patch shortly.
And also there's a mysterious ext4 data corruption that I do not really fully
understand but only hit once so far.