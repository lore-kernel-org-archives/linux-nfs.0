From: Harald Dunkel <harald.dunkel@aixigo.de>
Subject: mounting /var/lib/nfs with noatime or relatime ?
Date: Thu, 20 Aug 2009 09:10:00 +0200
Message-ID: <4A8CF6C8.1050400@aixigo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([195.14.232.227]:2141 "EHLO gate1.ac.aixigo.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753423AbZHTHZI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 03:25:08 -0400
Received: from srvl003.ac.aixigo.de (srvl003.ac.aixigo.de [172.19.96.13])
	by gate1.ac.aixigo.de (8.14.1/8.14.1) with ESMTP id n7K7A0Ni023771
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2009 09:10:00 +0200 (CEST)
Received: from [172.19.97.183] (localhost [127.0.0.1])
	by srvl003.ac.aixigo.de (8.12.6/8.12.6/SuSE Linux 0.6) with ESMTP id n7K7A0d6010083
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2009 09:10:00 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

NFS stores some small files in /var/lib/nfs, AFAICS.
Can it cause any problems for the NFService, if /var is
mounted with "relatime" or "noatime"? Does it increase
NFS performance at all?


Regards

Harri

