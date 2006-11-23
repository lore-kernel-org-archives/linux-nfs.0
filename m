From: Chris Caputo <ccaputo@alt.net>
Subject: Re: NFS hang
Date: Thu, 23 Nov 2006 07:40:23 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gn9C5-0003YP-5V
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 23:40:25 -0800
Received: from nacho.alt.net ([207.14.113.18])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gn9C6-0000qo-CM
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 23:40:26 -0800
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
In-Reply-To: <1162840599.31460.8.camel@zod.rchland.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 6 Nov 2006, Josh Boyer wrote:
> We've got an IBM bladecenter we're using to do some NFS stress testing
> (v3).  It seems with kernel 2.6.16.21 we get a hang during our stress
> tests after roughly and hour or two.  The hanging process has a
> backtrace that looks like this:
> 
> cp            D 000000000ff0b198  6672 16505  16296
> (NOTLB)
> Call Trace:
> [C00000000F43B1D0] [C00000002DD5B088] 0xc00000002dd5b088 (unreliable)
> [C00000000F43B3A0] [C00000000000F0B4] .__switch_to+0x12c/0x150
> [C00000000F43B430] [C00000000039980C] .schedule+0xcec/0xe4c
> [C00000000F43B540] [C00000000039A688] .io_schedule+0x68/0xb8
> [C00000000F43B5D0] [C000000000093D60] .sync_page+0x7c/0x98
> [C00000000F43B650] [C00000000039A8B4] .__wait_on_bit_lock+0x8c/0x114
> [C00000000F43B700] [C000000000093C94] .__lock_page+0xa0/0xc8
> [C00000000F43B820] [C000000000094A6C] .do_generic_mapping_read+0x21c/0x4a0
> [C00000000F43B970] [C000000000095624] .__generic_file_aio_read+0x17c/0x228
> [C00000000F43BA40] [C0000000000957C4] .generic_file_aio_read+0x44/0x54
> [C00000000F43BAD0] [D000000000320F58] .nfs_file_read+0xb8/0xec [nfs]
> [C00000000F43BB70] [C0000000000C5298] .do_sync_read+0xd4/0x130
> [C00000000F43BCF0] [C0000000000C60E0] .vfs_read+0x128/0x20c
> [C00000000F43BD90] [C0000000000C65C0] .sys_read+0x4c/0x8c
> [C00000000F43BE30] [C00000000000871C] syscall_exit+0x0/0x40
> 
> So far, we've only been able to recreate this with the client and server
> blades both in the same chassis.  We tried recreating with nfs_debug
> enabled, but it did not hang.  So perhaps there is a correlation with
> the high-speed network (gigabit ethernet over fibre) that comes with
> that configuration.
> 
> Does anyone recognize the backtrace of the process or the symptoms of
> the problem?  We'd appreciate any info that you may have.
> 
> Please CC me in responses as I'm not subscribed to this list.

Hi.  I am digging into a hang file issue (albeit NFSv2) that I've narrowed 
down to beginning with 2.6.11 and continuing to happen through 2.6.18, but 
which does not happen on 2.6.10 or prior.

I wonder if you could run your tests on 2.6.10 and 2.6.11.12 and share the 
results with me.

Thanks,
Chris

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
