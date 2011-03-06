Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from posta.eurosat.cz ([194.213.214.60]:58751 "EHLO mail.eurosat.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831Ab1CFX47 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Mar 2011 18:56:59 -0500
Received: from m50v.localnet (unknown [88.102.140.154])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.eurosat.cz (Postfix) with ESMTPSA id 0571C53C03F
	for <linux-nfs@vger.kernel.org>; Mon,  7 Mar 2011 00:56:57 +0100 (CET)
From: Ivo =?utf-8?q?P=C5=99ikryl?= <prikryl@eurosat.cz>
To: linux-nfs@vger.kernel.org
Subject: Re: Possible NFSv4 locking bug
Date: Mon, 7 Mar 2011 00:59:28 +0100
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <201103070059.28304.prikryl@eurosat.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello, 

just booted MDV 2010.2 with custom build 2.6.38 RC3 kernel, NFS4 server patched with your patch. 
So far it seems to be running just fine. No file descriptor wasted..

server#cat /proc/sys/fs/file-nr
960     0       1231794

I will give it more time to observe..


I can also confirm, that before it was impossible to umount the volume after file descriptors leakage. 
If you want me to test anything regarding this issue, I have system ready.

Thanks again 

Regards 
Ivo 
-- 
****************************************
Ivo Přikryl
prikryl@eurosat.cz
EuroSat cs spol.s r.o.
www.eurosat.cz
*****************************************
