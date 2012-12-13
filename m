Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tirith.ics.muni.cz ([147.251.4.36]:34018 "EHLO
	tirith.ics.muni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab2LMNwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 08:52:07 -0500
Received: from anubis.ics.muni.cz (anubis.ics.muni.cz [147.251.17.147])
	(authenticated user=xhejtman@META bits=0)
	by tirith.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id qBDDZs6Q004187
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 13 Dec 2012 14:35:55 +0100
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.80)
	(envelope-from <xhejtman@ics.muni.cz>)
	id 1Tj8x8-00009f-60
	for linux-nfs@vger.kernel.org; Thu, 13 Dec 2012 14:35:54 +0100
Date: Thu, 13 Dec 2012 14:35:54 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: local_lock mount option
Message-ID: <20121213133554.GO10897@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

is this option supported and should work?

It seems that in SLES and RHEL kernel, it is ignored:
mount nfs.server:/ /storage -t nfs4 -o sec=krb5,local_lock=all

cat /proc/mounts  | grep storage
nfs.server:/ /storage nfs4
rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=krb5,clientaddr=xxx.xxx.xxx.xxx,minorversion=0,local_lock=none,addr=xxx.xxx.xxx.xxx 0 0

and it seems, that it actually tries to lock through NFS.

Has this been fixed in later kernels or this is broken at all?

-- 
Luká¹ Hejtmánek
