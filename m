From: Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Tue, 26 Aug 2008 11:06:52 +1000
Message-ID: <6ik6b49cckum8u804lgl1tlf4sdkmh5sdk@4ax.com>
References: <1219400624.18774.67.camel@zakaz.uk.xensource.com> <1219428489.6919.21.camel@localhost> <1219428818.27921.43.camel@localhost.localdomain> <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com> <1219435207.27921.51.camel@localhost.localdomain> <1219440202.9097.14.camel@localhost> <1219441041.27921.57.camel@localhost.localdomain> <1219442213.9097.25.camel@localhost> <4156b4tgrrsflla1svmu4jl6j5sme4a715@4ax.com> <1219702272.7665.56.camel@localhost>
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="--=_cpl6b4t61tjeli91krdnia6o1b7rtbom8l.MFSBCHJLHS"
Cc: Grant Coady <gcoady.lk@gmail.com>,
	Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	John Ronciak <john.ronciak@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.mail-hub.dodo.com.au ([123.2.6.238]:40619 "EHLO
	relay03.mail-hub.dodo.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753200AbYHZBHM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 21:07:12 -0400
In-Reply-To: <1219702272.7665.56.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----=_cpl6b4t61tjeli91krdnia6o1b7rtbom8l.MFSBCHJLHS
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

On Mon, 25 Aug 2008 18:11:12 -0400, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

>On Tue, 2008-08-26 at 06:23 +1000, Grant Coady wrote:
>> On Fri, 22 Aug 2008 14:56:53 -0700, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>> 
>> >On Fri, 2008-08-22 at 22:37 +0100, Ian Campbell wrote:
>> >> I can ssh to the server fine. The same server also serves my NFS home
>> >> directory to the box I'm writing this from and I've not seen any trouble
>> >> with this box at all, it's a 2.6.18-xen box.
>> >
>> >OK... Are you able to reproduce the problem reliably?
>> >
>> >If so, can you provide me with a binary tcpdump or wireshark dump? If
>> >using tcpdump, then please use something like
>> >
>> >   tcpdump -w /tmp/dump.out -s 90000 host myserver.foo.bar and port 2049
>>                              ^^^^^^^^-->  typo?
>
>No. The intention was to record _all_ the info in the packet for
>analysis, not just random header info.

I booted 2.6.27-rc4-git4a and started the tcpdump trace as described in 
last email, got an immediate stall which cleared after 10-20 seconds, on 
running a small script exported from the NFS server as user:

~$ cat /home/common/bin/boot-report
#! /bin/bash
#
version=$(uname -r)

dmesg >/home/common/dmesg-$version

# 2006-12-15 no more filter .config
#grep = /boot/config-$version >/home/common/config-$version
cp /boot/config-$version /home/common


The script had not created the file on the server when the command prompt 
returned, during the stall I also opened another client terminal and ran 
'df', it stalled too, and both client terminals came back to prompt after 
the 10-20s delay.  Then I hit Ctrl-C on the tcpdump terminal to prepare 
this report.

The trace is only 27 lines, deltree is the server, pooh64 the client:
grant@pooh64:~$ /usr/sbin/tcpdump -r /tmp/dump.out00
reading from file /tmp/dump.out00, link-type EN10MB (Ethernet)
10:42:14.061410 IP pooh64.mire.mine.nu.0 > deltree.mire.mine.nu.nfs: 0 null
10:42:14.062691 IP deltree.mire.mine.nu.nfsd > pooh64.mire.mine.nu.839: S 2746115414:2746115414(0) ack 3659136038 win 5840 <mss 1460,nop,nop,sackOK>
10:42:14.062708 IP pooh64.mire.mine.nu.839 > deltree.mire.mine.nu.nfsd: . ack 1 win 5840
10:42:14.062750 IP pooh64.mire.mine.nu.1392480046 > deltree.mire.mine.nu.nfs: 112 getattr fh 0,1/218104576
10:42:14.062765 IP pooh64.mire.mine.nu.1409257262 > deltree.mire.mine.nu.nfs: 112 fsstat fh 0,1/218104576
10:42:14.062944 IP deltree.mire.mine.nu.nfsd > pooh64.mire.mine.nu.839: . ack 113 win 5840
10:42:14.062951 IP deltree.mire.mine.nu.nfsd > pooh64.mire.mine.nu.839: . ack 225 win 5840
10:42:14.063873 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1392480046: reply ok 116 getattr DIR 40755 ids 1000/10 sz 448
10:42:14.063881 IP pooh64.mire.mine.nu.839 > deltree.mire.mine.nu.nfsd: . ack 117 win 5840
10:42:14.063890 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1409257262: reply ok 88 fsstat tbytes 8422359040 fbytes 6605647872 abytes 6605647872
10:42:14.063893 IP pooh64.mire.mine.nu.839 > deltree.mire.mine.nu.nfsd: . ack 205 win 5840
10:42:14.064319 IP pooh64.mire.mine.nu.1426034478 > deltree.mire.mine.nu.nfs: 116 access fh 0,1/218104576 001f
10:42:14.064677 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1426034478: reply ok 124 access c 001f
10:42:14.064732 IP pooh64.mire.mine.nu.1442811694 > deltree.mire.mine.nu.nfs: 136 readdirplus fh 0,1/218104576 512 bytes @ 0
10:42:14.067193 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1442811694: reply ok 1460 readdirplus
10:42:14.067203 IP pooh64.mire.mine.nu.839 > deltree.mire.mine.nu.nfsd: . ack 1789 win 8760
10:42:14.067208 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.841889326: reply ok 1324
10:42:14.067328 IP pooh64.mire.mine.nu.1459588910 > deltree.mire.mine.nu.nfs: 112 getattr fh Unknown/010000000003000D0200000000000024010000060003000D02000000FE6F0000
10:42:14.068572 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1459588910: reply ok 116 getattr DIR 40755 ids 1000/10 sz 448
10:42:14.068619 IP pooh64.mire.mine.nu.1476366126 > deltree.mire.mine.nu.nfs: 136 getattr fh Unknown/010000060003000D02000000676A000002000000000000000200000001000000
10:42:14.070615 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1476366126: reply ok 116 getattr DIR 40755 ids 1000/10 sz 360
10:42:14.070652 IP pooh64.mire.mine.nu.1493143342 > deltree.mire.mine.nu.nfs: 140 access fh Unknown/010000060003000D02000000676A000002000000000000000200000001000000 001f
10:42:14.071576 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1493143342: reply ok 124 access c 001f
10:42:14.071638 IP pooh64.mire.mine.nu.1509920558 > deltree.mire.mine.nu.nfs: 160 readdirplus fh Unknown/010000060003000D02000000676A000002000000000000000200000001000000 512 bytes @ 0
10:42:14.073382 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.1509920558: reply ok 1460 readdirplus
10:42:14.074096 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.0: reply Unknown rpc response code=6 516
10:42:14.074102 IP pooh64.mire.mine.nu.839 > deltree.mire.mine.nu.nfsd: . ack 5445 win 17520

Sorry I forgot to do the netstat -t.

Attached the tcpdump file in case there's more info in it.

config and dmesg for client at:
  http://bugsplatter.id.au/kernel/boxen/pooh64/config-2.6.27-rc4-git4a
  http://bugsplatter.id.au/kernel/boxen/pooh64/dmesg-2.6.27-rc4-git4a

for server:
  http://bugsplatter.id.au/kernel/boxen/deltree/config-2.6.24.7a.gz
  http://bugsplatter.id.au/kernel/boxen/deltree/dmesg-2.6.24.7a.gz

Grant.

----=_cpl6b4t61tjeli91krdnia6o1b7rtbom8l.MFSBCHJLHS
Content-Type: application/octet-stream; name=dump.out00.gz
Content-Transfer-Encoding: base64
Content-Description: pooh64-2.6.27-rc4-git4a
Content-Disposition: attachment; filename=dump.out00.gz

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

----=_cpl6b4t61tjeli91krdnia6o1b7rtbom8l.MFSBCHJLHS--
