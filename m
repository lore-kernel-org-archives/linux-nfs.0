Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:33483 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281Ab3IYPaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Sep 2013 11:30:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1VOr2S-0006Rk-15
	for linux-nfs@vger.kernel.org; Wed, 25 Sep 2013 17:30:04 +0200
Received: from bitis.umrk.nl ([82.95.126.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 25 Sep 2013 17:30:04 +0200
Received: from jwinius by bitis.umrk.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 25 Sep 2013 17:30:04 +0200
To: linux-nfs@vger.kernel.org
From: Jaap <jwinius@umrk.nl>
Subject: Kerberos cfg for NFSv4
Date: Wed, 25 Sep 2013 15:21:54 +0000 (UTC)
Message-ID: <l1uv2i$jto$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

My site already has a working Kerberos system that allows users to access 
various services. To this end, all hosts already have a host/<hostname> 
principal with a full set of cryptographic keys. On the servers, besides 
the host keys in /etc/krb5.keytab, each Kerberized service has its own 
keytab: some with a full set of keys and others with only one (= weak 
crypto). Separate keytab files are maintained to prevent services from 
reading the wrong keys.

Therefore, on each of my servers the single key for NFSv4 will also need 
to be kept separate. With many Kerberized services, the Kerberos realm, 
service name and keytab file location can be specified somewhere. With 
others, the realm and service name are deduced from the contents of the 
keytab, but almost always the keytab location must be set somewhere: in a 
configuration file, or even with an environment variable. So how can this 
be configured for NFSv4?

Thanks,

Jaap

