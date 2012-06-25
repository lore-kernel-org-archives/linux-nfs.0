Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:47498 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752693Ab2FYHnK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2012 03:43:10 -0400
Content-Type: text/plain; charset="utf-8"
Date: Mon, 25 Jun 2012 09:43:06 +0200
From: "Johannes Schild" <JSchild@gmx.de>
Message-ID: <20120625074306.48500@gmx.net>
MIME-Version: 1.0
Subject: LAYOUTCOMMIT/LAYOUTRETURN
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Guys,

i have another question on pNFS. I looked at my Wireshark protocols, while i used the FILE-Layout, and i wondered why i have no LAYOUTCOMMIT/LAYOUTRETURN statements in my protocols.
I transfered one file to my storage server (NETAPP Simulator 8.1 C-Mode) and i only got a LAYOUTGET.

cat /proc/self/mountstats | grep LAYOUT says:
nfsv4: bm0=0xfafe8fff,bml=0x60fdfffe,acl=0x3,sessions,pnfs=LAYOUT_NFSV4_1_FILES
    LAYOUTGET: 1 1 0 216 236 0 1 1
 LAYOUTCOMMIT: 0 0 0 0 0 0 0 0
 LAYOUTRETURN: 0 0 0 0 0 0 0 0 


Is there any other way to verify that pnfs is used on client site?


Thanks in advance


Best Regards

Johannes



-- 
Empfehlen Sie GMX DSL Ihren Freunden und Bekannten und wir
belohnen Sie mit bis zu 50,- Euro! https://freundschaftswerbung.gmx.de
