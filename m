Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37941 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbbG3LFg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 07:05:36 -0400
Received: by wibxm9 with SMTP id xm9so63566725wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 04:05:35 -0700 (PDT)
Received: from [141.71.61.68] ([141.71.61.68])
        by smtp.gmail.com with ESMTPSA id lm5sm2412117wic.22.2015.07.30.04.05.34
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 04:05:34 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: Thomas <kuch3n@gmail.com>
Subject: NFS giving Access via DNS-Exports
Message-ID: <55BA04FE.6060908@gmail.com>
Date: Thu, 30 Jul 2015 13:05:34 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

my Network gots following topology:

Gateway I [10.1.0.1] lab01.labornetz.3315.
|---Row I [10.1.0.255].
\---Gateway II [10.1.0.2] lab11.labornetz.3315.
      |---Row II [10.2.0.255].
      \---Gateway III [10.2.0.1] lab21.labornetz.3315.
           \---Row III [10.3.0.255].

All of that Machines except for lab21 can Access the NFS-Shares with:

/srv/nfs4 
*.labornetz.3315(rw,fsid=0,no_subtree_check,nohide,anonuid=99,anongid=100)
/srv/nfs4/public *.labornetz.3315(rw,no_subtree_check,nohide)
/srv/nfs4/backups 
*.labornetz.3315(rw,no_subtree_check,nohide,root_squash,anonuid=99,anongid=100)

The nslookup for lab21 and reverse: http://nopaste.linux-dev.org/?664551
for lab11: http://nopaste.linux-dev.org/?664552

The /etc/exports file: http://nopaste.linux-dev.org/?664553

Output of 'tcpdump -i lan0 host 10.2.0.2 and port 2049 -n': 
http://nopaste.linux-dev.org/?664558

Uncommenting 17 and 18 will give access to Machine lab21, imho this is 
more a Workaround than a fix.

Any Suggestion on this?

Regards

