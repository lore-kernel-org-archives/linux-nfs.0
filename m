Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:55144 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754223Ab2DKITI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2012 04:19:08 -0400
Content-Type: text/plain; charset="utf-8"
Date: Wed, 11 Apr 2012 10:19:04 +0200
From: "Johannes Schild" <JSchild@gmx.de>
Message-ID: <20120411081904.72810@gmx.net>
MIME-Version: 1.0
Subject: Problems Setting up pNFS
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

i hope this is the right place to post my problem. Sorry for any inconvenience this is one of my first posts on a mailing list.

My problem is to set up pNFS. I used Fedora 16 with kernel 3.3.0-0.rc2.git1.1.pnfsd.fc17.x86_64.rpm from http://steved.fedorapeople.org/repos/pnfs/devel/x86_64/rpms/.
The following howto was used to set up the environment: http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd.
I tested with wireshark the connection between Metadataserver and Client and they use NFSv4.1. But my problem is with the layout... how can i tell the Metadataserver or the Client which layout could/must they use? Because spnfs is obsolete so iam a litte bit lost (i want to use a filelayout).
Maybe someone can give me a hint or further documentation?


Thanks in advance

regards

Johannes
-- 
NEU: FreePhone 3-fach-Flat mit kostenlosem Smartphone!                                  
Jetzt informieren: http://mobile.1und1.de/?ac=OM.PW.PW003K20328T7073a
