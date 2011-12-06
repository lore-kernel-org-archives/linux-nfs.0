Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651Ab1LFT4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 14:56:51 -0500
Message-ID: <4EDE737A.7090308@RedHat.com>
Date: Tue, 06 Dec 2011 14:56:42 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Orion Poplawski <orion@cora.nwra.com>, linux-nfs@vger.kernel.org
Subject: Re: rpc.gssd locks up with -vv or higher
References: <loom.20111206T175726-323@post.gmane.org> <20111206194159.GB11788@fieldses.org>
In-Reply-To: <20111206194159.GB11788@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2011 02:41 PM, J. Bruce Fields wrote:
> On Tue, Dec 06, 2011 at 05:01:13PM +0000, Orion Poplawski wrote:
>> See https://bugzilla.redhat.com/show_bug.cgi?id=667770
>>
>> Running rpc.gssd with -vvv, it will eventually hang.  Back trace of hung process:
>>
>> #0  0x00ae8416 in __kernel_vsyscall ()
>> #1  0x004be5d1 in __lll_lock_wait_private () from /lib/libc.so.6
>> #2  0x0044985c in _L_lock_12621 () from /lib/libc.so.6
>> #3  0x00447797 in malloc () from /lib/libc.so.6
>> #4  0x0043a398 in open_memstream () from /lib/libc.so.6
>> #5  0x004a9ae5 in __vsyslog_chk () from /lib/libc.so.6
>> #6  0x0017d15f in vsyslog (kind=512, 
>>     fmt=0x1806cc "dir_notify_handler: sig %d si %p data %p\n", args=0xbfc03938
>> "%")
>>     at /usr/include/bits/syslog.h:48
>> #7  xlog_backend (kind=512, fmt=0x1806cc "dir_notify_handler: sig %d si %p data
>> %p\n", 
>>     args=0xbfc03938 "%") at xlog.c:150
>> #8  0x001777d4 in printerr (priority=2, 
>>     format=0x1806cc "dir_notify_handler: sig %d si %p data %p\n") at
>> err_util.c:64
>> #9  0x00177c9e in dir_notify_handler (sig=37, si=0xbfc0396c, data=0xbfc039ec)
>>     at gssd_main_loop.c:66
>> #10 <signal handler called>
>> #11 0x00444984 in _int_malloc () from /lib/libc.so.6
>> #12 0x004477a0 in malloc () from /lib/libc.so.6
>> #13 0x0046db77 in __alloc_dir () from /lib/libc.so.6
>> #14 0x0046dc5a in opendir () from /lib/libc.so.6
>> #15 0x0046e7ef in scandir64@@GLIBC_2.2 () from /lib/libc.so.6
>> #16 0x00179285 in process_pipedir () at gssd_proc.c:565
>> #17 update_client_list () at gssd_proc.c:594
>> #18 0x00177f40 in gssd_run () at gssd_main_loop.c:216
>> #19 0x00177bf9 in main (argc=2, argv=0xbfc04134) at gssd.c:187
>>
>> Looks like malloc is getting called from a signal handler called while in a
>> malloc call, which is verboten.  Not sure what the best way around this, but it
>> looks like dir_notify_handler cannot call printerr.  I suppose this only occurs
>> when -vv or greater is given.  Path looks a little different in 1.2.5, but looks
>> like xlog_backend still calls vsyslog which can do the same thing.
> 
> Ha, that's interesting.
> 
> Maybe we should just delete that printerr.
I agree... That printerr was probably useful during the 
initial debugging but now it is probably just noise...

steved.
 
> 
> (If someone wanted to know when the notification came then it should be
> enough to add a printerr in update_client_list(), I think.)
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
