Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:53206 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab2HMKrk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 06:47:40 -0400
Received: by ghrr11 with SMTP id r11so2791240ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 03:47:39 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 13 Aug 2012 18:47:39 +0800
Message-ID: <CAPihpKCHm2a+oxH_Zu3UrzXHOTHJMCKcBhG=DcSR-Z4HjyK6Vg@mail.gmail.com>
Subject: Some XDR junk on nfs4_decode_dirent
From: Rodel Miguel <rodelfmiguel@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Guys,

I am trying to get some xattr information from the READDIR procedure.
I dumped the XDR stream at the nfs4_decode_dirent function and I found
out that the first time I do an "ls" command, I could see that the RPC
packet returns the READDIR response bytestream for a single directory
entry (on Wireshark) but does not correspond to the data that I see on
the nfs4_decode_dirent's first 80 bytes.  I could not see these first
80 bytes anywhere in the READDIR response and I guess the actual
bytestream for a directory entry got pushed by 80 bytes somehow when
it reached the nfs4_decode_dirent function.

I am using 3.4 kernel.  I have added the following code to the
nfs4_decode_dirent after all the variable declarations:

 int i;
        printk("starting xdr dump\r\n");
        for (i = 0; i < 128; i++) {
                if ((i % 4) == 0)
                        printk("\r\n\t");
                printk("%08x ", be32_to_cpu((unsigned long)xdr->p[i]));
        }


I have the following dump:

[838540.022906]         00000001 00000000 00000001 00000001 // this
looks like junk
[838540.022909]         2e000000 00000001 00100000 00000008 // this
looks like junk
[838540.022911]         00000000 00220002 00000001 00000000 // this
looks like junk
[838540.022914]         00000002 00000002 2e2e0000 00000001 // this
looks like junk
[838540.022916]         00100000 00000008 00000000 00220002 // this
looks like junk
[838540.022918]         00000001 185e632d 4a524b2a 00000011 // this
looks like proper data, i.e. it shows my folder name and some
attributes
[838540.022921]         73656c69 6e75782d 74657374 73756974 // this
looks like proper data
[838540.022923]         65000000 00000003 0018091a 00b0a23a // ..
[838540.022926]         00020000 000000cc 00000002 27a61b50 // ..
[838540.022928]         d1fbab35 00000000 00001000 00000000 ^M
[838540.022931]         00000000 00000000 00000000 00000000 ^M
[838540.022933]         00000010 01000101 00000000 00012200 ^M
[838540.022936]         704b90a3 00000000 00220100 000001ed ^M
[838540.022938]         00000006 00000005 36353533 34000000 ^M
[838540.022940]         00000005 36353533 34000000 00000000 ^M
[838540.022943]         00000000 00000000 00001000 00000000 ^M

Somehow, with this dump, the real data for decoding got pushed by 80
bytes.  Any clues about this problem?

Thank you very much for your help!

Kind Regards,
Rodel
