Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.linzag.at ([195.8.213.221]:21633 "EHLO mail1.linzag.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab0J1JkI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 05:40:08 -0400
Received: from smtp-o.linzag.at (localhost [127.0.0.1])
	by smtp-v1.linzag.at (Virusserver I Mailexchange - Linz AG) with ESMTP id C9C2E4BB0D
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 11:40:06 +0200 (CEST)
Received: from mail-o.ugl.linz.at (unknown [10.216.6.1])
	by smtp-o.linzag.at (internal Mailexchange - Linz AG) with ESMTP id BDA5E4BAC6
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 11:40:06 +0200 (CEST)
From: Schobesberger Martin <Martin.Schobesberger@ikt.linz.at>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 28 Oct 2010 11:40:05 +0200
Subject: NFS Server / Client Configuration with SLES 11  / SUSE Linux 8
Message-ID: <A0EB63F3ACD2034DAE7B25DB677DDA6E8AECBDC67E@UGLCL01-MXS.ugl.linz.at>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


I hope this is the rigth mail-list for my question :-)

Hi Together

With SUSE Linux 8 I had following scenario with 3 Servers, that functioned quite well

Server A: NFS-Exports /test
Server B: Mounts serverA:/test in /mnt/test
Server B: NFS-Exports /mnt/test (Same Mountpoint)
Server C: Mounts serverB:/mnt/test

Works very well


Under SLES 11 this constallation doesn't work: when trying to mount from Server C: Errors like "Permission denied"  appears:

Used NFS-Client in SLES 11 :

lagast01:/mnt/testsamba # modinfo nfs
filename:       /lib/modules/2.6.27.19-5-default/kernel/fs/nfs/nfs.ko
license:        GPL
author:         Olaf Kirch <okir@monad.swb.de>
srcversion:     D1320014A391481DEE0FA97
depends:        sunrpc,lockd,nfs_acl
supported:      yes
vermagic:       2.6.27.19-5-default SMP mod_unload modversions
parm:           enable_ino64:bool

lagast01:/mnt/testsamba # modinfo lockd
filename:       /lib/modules/2.6.27.19-5-default/kernel/fs/lockd/lockd.ko
license:        GPL
description:    NFS file locking service version 0.5.
author:         Olaf Kirch <okir@monad.swb.de>
srcversion:     3CB3F907F89F9040E2C385F
depends:        sunrpc
supported:      yes
vermagic:       2.6.27.19-5-default SMP mod_unload modversions
parm:           nsm_use_hostnames:bool
lagast01:/mnt/testsamba #


DO YOU HAVE ANY HINT FOR ME if there is an parameter, which I could use, to get in functional like in SUSE 8 !?



THANKS a lot

with best regards

martin




Diese Nachricht inklusive aller Anh?nge kann vertrauliche Informationen enthalten. Sie ist ausschlie?lich f?r die adressierten Personen bestimmt. Das unerlaubte Kopieren sowie die unbefugte Weitergabe sind nicht gestattet. Sollten Sie nicht die richtige Adressatin/der richtige Adressat sein, vernichten Sie den gesamten Inhalt (? 93 Abs. 4 Telekommunikationsgesetz 2003) und informieren Sie bitte sofort den/die Absender/in. N?here Regelungen zur elektronischen Kommunikation mit der Stadt Linz finden Sie in den "Allgemeinen Hinweisen und Nutzungsbestimmungen betreffend das E-Government der Stadt Linz (e-linz)" ( http://www.linz.at/images/AGB_egov_2008.pdf )

IKT Linz GmbH, Firmenbuch des Landesgerichtes Linz ++ Firmenbuch-Nummer: 321197z ++ UID-Nummer: ATU64636344
IKT Linz Infrastruktur GmbH,  Firmenbuch des Landesgerichtes Linz ++ Firmenbuch-Nummer: 321990s  ++ UID-Nummer: ATU64664303
A-4020 Linz, Gruberstra?e 42, Tel. +43 732 7070 0, Fax: +43 732 7070 54 1555, office@ikt.linz.at, www.linz.at/ikt
