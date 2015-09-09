Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33870 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbIIRpL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2015 13:45:11 -0400
Received: by padhy16 with SMTP id hy16so16560536pad.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2015 10:45:11 -0700 (PDT)
Date: Wed, 9 Sep 2015 10:45:08 -0700
From: Tom Haynes <thomas.haynes@primarydata.com>
To: nfsv4@ietf.org, linux-nfs@vger.kernel.org
Subject: NFSv4.2 wireshark
Message-ID: <20150909174508.GA2445@skull>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've contributed the remaining changes needed to have wireshark decode NFSv4.2:

8a8a82d nfs: Add NFSv4.2 op LAYOUTERROR
0c6b54e nfs: Add support for the Flex File Layout Type in LAYOUTRETURN
0f89e42 nfs: Add NFSv4.2 op LAYOUTSTATS
6b59566 nfs: Add NFSv4.2 op WRITE_SAME
0fdd702 nfs: Add NFSv4.2 op READ_PLUS
720a759 nfs: Add NFSv4.2 cb op CB_OFFLOAD
9e07406 nfs: Add NFSv4.2 op IO_ADVISE
b5aa0ff nfs: Add NFSv4.2 ops OFFLOAD_CANCEL and OFFLOAD_STATUS
c782824 nfs: Add NFSv4.2 op CLONE
2160e9c nfs: Add NFSv4.2 ops COPY and COPY_NOTIFY
79b88aa nfs: Cleanup of FlexFiles Layout Type
6e82854 nfs: Add new attributes for NFSv4.2
a79967f nfs: Add new error codes for NFSv4.2

These are in the bleeding edge 1.99.9:

git clone https://code.wireshark.org/review/wireshark

I have no idea when these will pop into the mainstream.

Note, they do build on earlier changes I provided and those
also are in the bleeding edge and not in the mainstream.

Enjoy,
Tom
