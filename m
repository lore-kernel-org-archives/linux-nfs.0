Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from extranet.sessys.com ([50.116.54.220]:40973 "EHLO
	extranet.sessys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbbFCNwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 09:52:30 -0400
Received: from extranet.sessys.com (localhost [127.0.0.1])
	by extranet.sessys.com (8.14.4/8.14.4-SES__EXTERNAL) with ESMTP id t53DdsfG020165
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Jun 2015 09:39:54 -0400
To: linux-nfs@vger.kernel.org
Subject: rpc.nfsd Host Option & IPv6
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 03 Jun 2015 09:39:53 -0400
From: Sean Elble <elbles@sessys.com>
Message-ID: <b66b20ec16b59568246f454bfbbfd5e9@mail.sessys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

While it seems that most folks use iptables to restrict access to single 
interfaces when multihomed hosts are acting as NFS servers, I do see 
that there is a "--host" option that can be provided to rpc.nfsd when it 
starts so that it only binds to a specific IP/interface.

This does seem to work nicely, but when I try to use it, it throws an 
error/warning (where nfs-server is defined in /etc/hosts for the IPv4 
address of the interface I wish for TCP port 2049 to be opened on):

rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name or 
service not known

Commenting out the following lines in /etc/netconfig (as suggested by 
the Google) allows the daemon to start without error:

udp6       tpi_clts      v     inet6    udp     -       -
tcp6       tpi_cots_ord  v     inet6    tcp     -       -

But I'm wondering if that is the only means for this to work, 
particularly considering that I'd expect changes to /etc/netconfig to 
apply to more than just rpc.nfsd.

It is worth noting that 1) this seems to apply equally to Debian-based 
and RHEL-based systems and 2) things seem to work even with the error, 
but I wouldn't have expected to see that message for something 
(seemingly) so simple.

Any and all thoughts are welcome.

Thanks,

Sean
