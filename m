Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailpro.odiso.net ([89.248.209.98]:60945 "EHLO
	mailpro.odiso.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758835Ab3APKxc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2013 05:53:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by mailpro.odiso.net (Postfix) with ESMTP id 447461802797C
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2013 11:44:10 +0100 (CET)
Received: from mailpro.odiso.net ([127.0.0.1])
	by localhost (mailpro.odiso.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id R3gpi4-xfG0b for <linux-nfs@vger.kernel.org>;
	Wed, 16 Jan 2013 11:44:04 +0100 (CET)
Received: from mailpro.odiso.net (mailpro.odiso.net [10.1.31.112])
	by mailpro.odiso.net (Postfix) with ESMTP id BE7F518036862
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2013 11:44:04 +0100 (CET)
Date: Wed, 16 Jan 2013 11:44:04 +0100 (CET)
From: Alexandre DERUMIER <aderumier@odiso.com>
To: linux-nfs@vger.kernel.org
Subject: pnfs : mount on 2 mds for failover ?
Message-ID: <b35f113f-839e-4450-91f9-6531c9196ae2@mailpro>
In-Reply-To: <a9eff23a-624d-46b6-bd07-1983b1309cfe@mailpro>
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi List,

I'm building a netapp c-mode pnfs cluster, each netapp node is a mds and data server.


I would like to known if it's possible to mount from 2 mds server with linux client ?


Currently I'm trying with roundrobin dns, kernel 3.7.1, (tried with inkernel dns resolver and legacy resolver)

netapp.nfs A 192.168.0.1
netapp.nfs A 192.168.0.2


mounted with

options minorversion=1,rw,noatime,nodiratime,noacl,vers=4,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600


But if first mds goes down, the mount hang, and doesn't seem to try on second mds.


Does I need to use soft mount ?

Best Regards,

Derumier Alexandre
