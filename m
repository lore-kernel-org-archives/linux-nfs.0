Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:42924 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411AbaGBRnI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jul 2014 13:43:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1X2OYi-0000rT-Cf
	for linux-nfs@vger.kernel.org; Wed, 02 Jul 2014 19:43:04 +0200
Received: from bitis.umrk.nl ([82.95.126.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 19:43:04 +0200
Received: from jwinius by bitis.umrk.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 19:43:04 +0200
To: linux-nfs@vger.kernel.org
From: Jaap Winius <jwinius@umrk.nl>
Subject: NFSv4 cross-realm support
Date: Wed, 2 Jul 2014 17:42:51 +0000 (UTC)
Message-ID: <lp1gar$eb6$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Recently I've been working on cross-realm support to give my own MIT 
Kerberos realm, UMRK.NL, access to the services of a realm that I manage. 
All systems involved run Debian wheezy. So far, SSH, OpenLDAP, OpenAFS 
and Dovecot IMAP are all working properly this way, but NFSv4 with 
sec=krb5i is not; I keep getting "Permission denied" when attempting to 
read or write to any file or directory that is not globally accessible.

When the log output verbosity for rpc.gssd and rpc.svcgssd is increased 
about as far as it will go (-vvvvv), little is different when things go 
wrong, other than this one line produced by rpc.svcgssd on the server:

  nss_gss_princ_to_ids: Local-Realm 'UMRK.NL': NOT FOUND

However, even that seems a bit misleading, because the log output for 
rpc.idmapd (with Verbosity = 5) shows that the user and group IDs for my 
account are being identified properly.

Should I prepare a bug report for this issue, or does cross-realm support 
for NFSv4 require something extra?

Thanks,

Jaap

