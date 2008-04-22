From: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Subject: Problem with krb5 authentification, server under a NAT
Date: Tue, 22 Apr 2008 18:19:09 +0200
Message-ID: <20080422161908.GC11221@goelette.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:1415 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752874AbYDVQTP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2008 12:19:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a problem with krb5 authentification and nfsv4:

basically the server is behind a NAT which over I do not have much control.
To mount exported partitions I use socat on the NAT and redirect some TCP port
(actually 2050 because 2049 is firewalled) to the port 2049 on the server. I
can successfuly mount with auth=sys,port=2050, but I am unable to mount with
kerberos authentification. The problem seems to lie within rpc.gssd which does
not care for the port setting and tries to contact the server on port 2049.

I suppose the same could happen with nfsv{2,3} (provided the mountd port is
redirected as well)

Is this a problem you were aware of?

I suppose fixing it may require a change in the callback between the kernel
and rpc.gssd?

Regards,
Quentin Godfroy
