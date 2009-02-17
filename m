From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Subject: redundant reverse DNS on NFS mount or umount
Date: Tue, 17 Feb 2009 15:22:35 +0000
Message-ID: <499AD63B.20806@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail122.emailantidote.com ([80.169.59.122]:52341 "EHLO
	SC-MTA-03.mxsweep.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752210AbZBQPc7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 10:32:59 -0500
Received: from [192.168.2.25] (crom.labs.lincor.com [192.168.2.25])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by tombstone.lincor.com (Postfix) with ESMTP id 5A35E601376D
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2009 15:22:35 +0000 (GMT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've a problem where reverse DNS is being done by the NFS server.
This is very problematic when the DNS server goes away.
As far as I can see there should be no lookups being performed
because I've nothing in /etc/hosts.{allow,deny} and just
numeric hosts in /etc/exports.

I can simulate this easily by putting a bad nameserver in /etc/resolv.c=
onf
and restarting the nfs server. Any mounts will take then take ages.
Others seem to have had this issue as well, but possibly with
non numeric names in /etc/exports:
http://marc.info/?l=3Dlinux-nfs&m=3D110977757630297&w=3D2
http://marc.info/?l=3Dlinux-nfs&m=3D111015343008456&w=3D2

Here are my config details:

# rpm -q nfs-utils
nfs-utils-1.1.0-6.fc8

# cat /etc/resolv.conf
search company.com
nameserver 192.168.2.110

# cat /etc/exports
/home   192.168.2.25(async,rw,all_squash,anonuid=3D500,anongid=3D500)

Any ideas appreciated.

cheers,
P=C3=A1draig.
