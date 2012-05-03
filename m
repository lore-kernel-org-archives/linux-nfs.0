Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36838 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753141Ab2ECDlT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 23:41:19 -0400
Received: from loghyr.hq.netapp.com (loghyr.hq.netapp.com [10.34.16.47])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q433f2WY019082
	for <linux-nfs@vger.kernel.org>; Wed, 2 May 2012 20:41:02 -0700 (PDT)
Received: from loghyr.hq.netapp.com (localhost.localdomain [127.0.0.1])
	by loghyr.hq.netapp.com (8.14.5/8.14.5) with ESMTP id q433f20R024588
	for <linux-nfs@vger.kernel.org>; Wed, 2 May 2012 20:41:02 -0700
Received: (from thomas@localhost)
	by loghyr.hq.netapp.com (8.14.5/8.14.5/Submit) id q433f2S9024587
	for linux-nfs@vger.kernel.org; Wed, 2 May 2012 20:41:02 -0700
Date: Wed, 2 May 2012 20:41:01 -0700
From: Tom Haynes <thomas@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: Difference in tshark displays
Message-ID: <20120503034101.GA24583@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On my Arch client, tshark (version 1.6.7) displays a single procedure out of the compound.

[thomas@psyklo tmp]$ sudo tshark "host 192.168.2.102 && host 192.168.2.105" -R nfs
tshark: Lua: Error during loading:
 [string "/usr/share/wireshark/init.lua"]:45: dofile has been disabled
Running as user "root" and group "root". This could be dangerous.
Capturing on eth0
  0.000000 192.168.2.102 -> 192.168.2.105 NFS 306 V4 Call OPEN DH:0x7d7d8f5e/.gitconfig
  0.000232 192.168.2.105 -> 192.168.2.102 NFS 522 V4 Reply (Call In 1) OPEN StateID:0x219c
  0.000331 192.168.2.102 -> 192.168.2.105 NFS 206 V4 Call GETATTR FH:0xa109f3ab
  0.000481 192.168.2.105 -> 192.168.2.102 NFS 302 V4 Reply (Call In 4) GETATTR
  0.000586 192.168.2.102 -> 192.168.2.105 NFS 222 V4 Call READ StateID:0x0451 Offset:0 Len:142
  0.000812 192.168.2.105 -> 192.168.2.102 NFS 274 V4 Reply (Call In 6) READ
  0.000874 192.168.2.102 -> 192.168.2.105 NFS 230 V4 Call CLOSE StateID:0x219c
  0.001103 192.168.2.105 -> 192.168.2.102 NFS 202 V4 Reply (Call In 8) CLOSE
[thomas@psyklo thomas]$ tshark -v
TShark 1.6.7 (SVN Rev Unknown from unknown)

On my Fedora 15 server, tshark (version 1.4.12) displays all of the procedures in the compound:

[thomas@wont ~]$ sudo tshark "host 192.168.2.102 && host 192.168.2.105" -R nfs
Running as user "root" and group "root". This could be dangerous.
Capturing on eth0
  0.000258 192.168.2.102 -> 192.168.2.105 NFS V4 COMP Call PUTFH GETATTR
  0.000610 192.168.2.105 -> 192.168.2.102 NFS V4 COMP Reply (Call In 6) PUTFH GETATTR
  0.000940 192.168.2.102 -> 192.168.2.105 NFS V4 COMP Call PUTFH ACCESS GETATTR
  0.000973 192.168.2.105 -> 192.168.2.102 NFS V4 COMP Reply (Call In 10) PUTFH ACCESS GETATTR
  0.001169 192.168.2.102 -> 192.168.2.105 NFS V4 COMP Call PUTFH GETATTR
  0.001203 192.168.2.105 -> 192.168.2.102 NFS V4 COMP Reply (Call In 12) PUTFH GETATTR
  0.001425 192.168.2.102 -> 192.168.2.105 NFS V4 COMP Call PUTFH ACCESS GETATTR
  0.001459 192.168.2.105 -> 192.168.2.102 NFS V4 COMP Reply (Call In 14) PUTFH ACCESS GETATTR
[thomas@wont ~]$ tshark -v
TShark 1.4.12

Is there anyway to have the output display all of the procedures on one line like with the old format?

I.e., sometimes it is nice to have the new way, a quick summary, but other times I'd like to be able
to see the summary of the whole compound.

-- 
thomas@netapp.com, ex-cfb
