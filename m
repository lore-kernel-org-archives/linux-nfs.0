Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:58360 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbaEXQVI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 May 2014 12:21:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1WoEgz-0001RF-Ne
	for linux-nfs@vger.kernel.org; Sat, 24 May 2014 18:21:05 +0200
Received: from bitis.umrk.nl ([82.95.126.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 24 May 2014 18:21:05 +0200
Received: from jwinius by bitis.umrk.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 24 May 2014 18:21:05 +0200
To: linux-nfs@vger.kernel.org
From: Jaap <jwinius@umrk.nl>
Subject: NFSv4 with Kerberos and no_root_squash
Date: Sat, 24 May 2014 16:20:58 +0000 (UTC)
Message-ID: <llqgta$3d3$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Not long ago I managed to get NFSv4 to work together with Kerberos (gss/
krb5i or gss/krb5p), but apparently there's a limitation. It has to do 
with exports that include the "no_root_squash" option and then attempting 
to allow root on the clients to write to them; this always results in a 
"Permission denied" error.

Is there a solution for this, or a workaround?

For me this is important, because one of the sites I maintain uses NFS 
for home directories and the workstations have an elaborate logout script 
in /etc/X11/Xreset.d/ that runs as root (the script contains many sudo 
commands to make changes to the user's home directories). Therefore, one 
solution would be to avoid running the logout script as root, but AFAIK 
that's not possible.

Thanks,

Jaap

