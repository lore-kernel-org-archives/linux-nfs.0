Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm5-vm0.bullet.mail.ird.yahoo.com ([77.238.189.207]:21770 "EHLO
	nm5-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754464Ab3FDOm0 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 10:42:26 -0400
References: <1370356211.25850.YahooMailNeo@web133002.mail.ir2.yahoo.com>
Message-ID: <1370356944.97048.YahooMailNeo@web133005.mail.ir2.yahoo.com>
Date: Tue, 4 Jun 2013 15:42:24 +0100 (BST)
From: Errembault Philippe <philippe_errembault@yahoo.fr>
Reply-To: Errembault Philippe <philippe_errembault@yahoo.fr>
Subject: strange behaviour when sharing the root filesystem
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1370356211.25850.YahooMailNeo@web133002.mail.ir2.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, 

This may be an early report, since I haven't toroughtfully tested it yet, 
and I'm not sure if this is abnormal or not. I haven't found any source 
allowing me to think it might be normal. 
I have observed that if I mount my root filesystem on a second 
mounting point, and try to share it with nfs-kernel-server, mounting 
if on a client will only show me directories shared womewhere else .

let's say my root is /dev/sda1, then I do
    myserver> mkdir /media/rootbis
    myserver> mount /dev/sda1 /media/rootbis

and I configure /etc/exports : 
    /usr            myclient(rw,no_root_squash,no_subtree_check)
    /home           myclient(rw,no_root_squash,no_subtree_check)
    /media/rootbis  myclient(rw,no_root_squash,no_subtree_check)

and activate it
    myserver> exportfs -ra

then mount it on the client
    myclient> mount -t nfs myserver:/media/rootbis mymountpoint

and examine the content of the share, I only see the directorie which were otherwise shared
    myclient> ls -l mymountpoint
    usr  home  media

I needed to share explicitely my root to be able to see my whole rootbis share.
