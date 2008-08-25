From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: [NFS] linux-2.6.27-rc3: kernel BUG at fs/nfs/write.c:252
Date: Mon, 25 Aug 2008 12:01:15 +0200
Message-ID: <48B282EB.6030306__45117.6870301881$1219659446$gmane$org@bull.net>
References: <48AE6C38.9040507@bull.net> <20080822190452.GA3868@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: nfs@lists.sourceforge.net,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	nfsv4 <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:37336 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbYHYKCi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 06:02:38 -0400
In-Reply-To: <20080822190452.GA3868@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields a =E9crit :

>On Fri, Aug 22, 2008 at 09:35:20AM +0200, Le Rouzic wrote:
> =20
>
>>Hi,
>>Client and server On Intel X86_64 with linux-2.6.27-rc3.
>>
>>Doing several stress benchmarks simultaneously:
>>fsstress
>>iozone   (without  -U )
>>fsx
>>ffsb
>>cthon
>>
>>The server crashed.
>>
>>Here is the trace on the server:
>>   =20
>>
>
>You're sure it's the server?  This crash is in client code.
>
>--b.
> =20
>

    Hi,
    You are right. It's on the client side .
    Sorry about that.
    I made the confusion because this time I inversed the role of my=20
machines.
    I can reproduced it . It happens also faster in loopback.

    Cheers

> =20
>
>>------------[ cut here ]------------
>>kernel BUG at fs/nfs/write.c:252!
>>
>>Entering kdb (current=3D0xffff8800621c78d0, pid 25953) on processor 1=
 due to
>>KDB_ENTER()
>>[1]kdb> bt
>>Stack traceback for pid 25953
>>0xffff8800621c78d0    25953     5308  1    1   R  0xffff8800621c7c38 =
*fsx-linux
>>sp                ip                Function (args)
>>0xffff8800660cdb88 0xffffffff80330871 nfs_do_writepage+0xe7
>>(0xffffe20001770140, invalid, 0xffff8800660cdd18)
>>0xffff8800660cdbf0 0xffffffff80330cd0 nfs_writepages_callback+0xf
>>(0xffffe20001770140)
>>0xffff8800660cdc10 0xffffffff802657f9 write_cache_pages+0x1ca
>>(0xffff880062402468, 0xffff8800660cddc8, 0xffffffff80330cc1,
>>0xffff8800660cdd18)
>>0xffff8800660cdd10 0xffffffff80330c95 nfs_writepages+0x72 (0xffff8800=
62402468,
>>0xffff8800660cddc8)
>>0xffff8800660cdd90 0xffffffff803315b6 __nfs_write_mapping+0x19
>>(0xffff880062402468, 0xffff8800660cddc8, invalid)
>>0xffff8800660cddc0 0xffffffff80331655 nfs_write_mapping+0x68
>>(0xffff880062402468, invalid)
>>0xffff8800660cde30 0xffffffff80331675 nfs_wb_nocommit+0x15 (invalid)
>>0xffff8800660cde40 0xffffffff80327638 nfs_getattr+0x5c (0xffff88007fb=
bf1c0,
>>invalid, 0xffff8800660cdef8)
>>0xffff8800660cde80 0xffffffff8028c637 vfs_getattr+0x44 (0xffff88007fb=
bf1c0,
>>0xffff8800664e00b8, 0xffff8800660cdef8)
>>0xffff8800660cdec0 0xffffffff8028c687 vfs_fstat+0x33 (invalid,
>>0xffff8800660cdef8)
>>0xffff8800660cdef0 0xffffffff8028c6b8 sys_newfstat+0x1a (invalid,
>>0x7fffec90f890)
>> not matched: from 0xffffffff8020bead to 0xffffffff8020bf25 drop_thro=
ugh 0
>>bb_jmp[7]
>>bb_special_case: Invalid bb_reg_state.memory, missing trailing entrie=
s
>>bb_special_case: on transfer to int_with_check
>> system_call_fastpath has memory parameters but no register parameter=
s.
>> Assuming it is a 'pass through' function that does not refer to its =
register
>> parameters and setting 6 register parameters
>>kdb_bb: 0xffffffff8020be3b [kernel]system_call_fastpath failed at
>>0xffffffff8020bec8
>>
>>Using old style backtrace, unreliable with no arguments
>>sp                ip                Function (args)
>>0xffff8800660cdb88 0xffffffff80330871 nfs_do_writepage+0xe7
>>0xffff8800660cdbb0 0xffffffff80330871 nfs_do_writepage+0xe7
>>0xffff8800660cdbf0 0xffffffff80330cd0 nfs_writepages_callback+0xf
>>0xffff8800660cdc10 0xffffffff802657f9 write_cache_pages+0x1ca
>>0xffff8800660cdc20 0xffffffff80330cc1 nfs_writepages_callback
>>0xffff8800660cdc68 0xffffffff8032d3bc nfs_wait_bit_killable
>>0xffff8800660cdc80 0xffffffff80603a87 out_of_line_wait_on_bit+0x6e
>>0xffff8800660cdca8 0xffffffff8023f9b8 wake_bit_function
>>0xffff8800660cdd10 0xffffffff80330c95 nfs_writepages+0x72
>>0xffff8800660cdd50 0xffffffff80331c41 nfs_flush_one
>>0xffff8800660cdd90 0xffffffff803315b6 __nfs_write_mapping+0x19
>>0xffff8800660cddc0 0xffffffff80331655 nfs_write_mapping+0x68
>>0xffff8800660cde30 0xffffffff80331675 nfs_wb_nocommit+0x15
>>0xffff8800660cde40 0xffffffff80327638 nfs_getattr+0x5c
>>0xffff8800660cde80 0xffffffff8028c637 vfs_getattr+0x44
>>0xffff8800660cdec0 0xffffffff8028c687 vfs_fstat+0x33
>>0xffff8800660cdef0 0xffffffff8028c6b8 sys_newfstat+0x1a
>>0xffff8800660cdf40 0xffffffff80242540 up_write+0x9
>>0xffff8800660cdf50 0xffffffff802731c5 sys_munmap+0x4d
>>
>>Bug registered at:
>>
>>
>>
>>------------------------------------------------------------- Bug: =20
>>http://bugzilla.linux-nfs.org/show_bug.cgi?id=3D168=20
>>
>>
>>
>>Best Regards
>>
>>--=20
>>-----------------------------------------------------------------
>>Company : Bull, Architect of an Open World TM (www.bull.com)
>>Name    : Aime Le Rouzic Mail    : Bull - BP 208 - 38432 Echirolles C=
edex=20
>>- France
>>E-Mail  : aime.le-rouzic@bull.net
>>Phone   : 33 (4) 76.29.75.51
>>Fax     : 33 (4) 76.29.75.18
>>-----------------------------------------------------------------=20
>>
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>   =20
>>
>
>----------------------------------------------------------------------=
---
>This SF.Net email is sponsored by the Moblin Your Move Developer's cha=
llenge
>Build the coolest Linux based applications with Moblin SDK & win great=
 prizes
>Grand prize is a trip for two to an Open Source event anywhere in the =
world
>http://moblin-contest.org/redirect.php?banner_id=3D100&url=3D/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>_______________________________________________
>Please note that nfs@lists.sourceforge.net is being discontinued.
>Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" i=
n
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> =20
>


--=20
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic=20
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
=46ax     : 33 (4) 76.29.75.18
-----------------------------------------------------------------=20

