From: Tao Guo <glorioustao@gmail.com>
Subject: Re: [PATCH] pnfsblock: Lookup list entry of layouts and tags in
	reverse order
Date: Thu, 20 May 2010 13:44:13 +0800
Message-ID: <AANLkTikEOhpGbCEAkxvDC93B1lM6d_htL_TOfjFOpAsD@mail.gmail.com>
References: <4BEA4ED3.3010702@panasas.com>
	 <20100517135341.GA30737@fieldses.org> <4BF151A7.1070003@panasas.com>
	 <20100517145311.GJ30737@fieldses.org>
	 <20100517165302.GL30737@fieldses.org>
	 <AANLkTilUpAHrtHH8pauvYrAuD3rWgj7aDmrTOzrmU-h5@mail.gmail.com>
	 <20100518162005.GI17823@fieldses.org>
	 <AANLkTik9L15tqpSboBpb9cSTy3hVPLEK487w94pEbLrS@mail.gmail.com>
	 <20100519163632.GL4581@fieldses.org>
	 <20100519213849.GR9720@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51148 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652Ab0ETFoP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 01:44:15 -0400
Received: by vws9 with SMTP id 9so4474376vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 May 2010 22:44:14 -0700 (PDT)
In-Reply-To: <20100519213849.GR9720@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Fields
I used the connectathon general test with my latest code, and it
passed the tests.
Can you just try the two patches I have sent in the mailing list to
see if it helps?

On Thu, May 20, 2010 at 5:38 AM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Wed, May 19, 2010 at 12:36:32PM -0400, J. Bruce Fields wrote:
>> On Wed, May 19, 2010 at 12:56:42PM +0800, Tao Guo wrote:
>> > I think the warning just indicate a possible bug:
>> > nfs_inode_set_delegation():
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 clp->cl_lock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 --> inode->i_lock
>> > get_lock_alloc_layout():
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->lo_loc=
k
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 --> =
clp->cl_lock
>> > nfs_try_to_update_request()->pnfs_do_flush()->_pnfs_do_flush()->
>> > pnfs_find_get_lseg()->get_lock_current_layout():
>> >
>> > inode->i_lock
>> >
>> > -->nfsi->lo_lock
>> > In nfs_inode_set_delegation(), maybe we should unlock clp->cl_lock=
 before
>> > taking inode->i_lock spinlock?
>> >
>> > PS: I just use the latest pnfsblock code(pnfs-all-2.6.34-2010-05-1=
7) doing some
>> > basic r/w tests and it works fine.
>>
>> Could you try running the connectathon general test?
>>
>> > Can you find out which code path
>> > lead to IO errror?
>>
>> I'll try to narrow down the test case.
>
> I haven't gotten the chance to narrow it down any more. =C2=A0So all =
I can
> say is that:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0~/cthon04# NFSTESTDIR=3D/mnt/TMP ./runtest=
s -g
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0GENERAL TESTS: directory /mnt/TMP
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if test ! -x runtests; then chmod a+x runt=
ests; fi
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cd /mnt/TMP; rm -f Makefile runtests runte=
sts.wrk *.sh *.c
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mkdummy rmdummy nroff.in makefile.tst
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cp Makefile runtests runtests.wrk *.sh *.c=
 mkdummy rmdummy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nroff.in makefile.tst /mnt/TMP
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Small Compile
> =C2=A0 =C2=A0 =C2=A0 =C2=A0runtests.wrk: 63: ./stat: Input/output err=
or
> =C2=A0 =C2=A0 =C2=A0 =C2=A0general tests failed
>
> is a consistent result for me. =C2=A0(Using the tests from
> http://www.connectathon.org/nfstests.html.)
>
> --b.
>



--=20
tao.
