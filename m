Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45596 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbbG3C2W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jul 2015 22:28:22 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: managing the system's NFSv4 domain name
Date: Wed, 29 Jul 2015 22:28:16 -0400
Message-Id: <5E5505A2-44BA-4ED7-89A6-8639C0D068BF@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Anna Schumaker <schumakeranna@gmail.com>,
        Steve Dickson <SteveD@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

At least for testing purposes, it would be great to be able to
manage a system's NFSv4 domain name from the command line. I'm
frequently asked how to determine a system's NFSv4 domain name,
and I'm forced to answer something like this:

> Linux does not currently have a command line tool for managing
> the system's NFSv4 idmapping domain. Use:
> 
> awk '/^Domain/ { print $3 }' < /etc/idmapd.conf
> 
> If that fails to find anything, then use `dnsdomainname` . That
> won't be helpful if the system has multiple i/f's.


This doesn't even get into /proc/keys, or what to do to change
the NFSv4 domainname, or the differences between rpc.idmapd and
the keyring-based idmapper.

Linux now has hostnamectl and other tools to manage a system's
hostname and so on. Solaris has sharectl, which can display and
update the nfs4mapid_domain.

Does it make sense to extend the nfsidmap command to display and
modify the NFSv4 domain name?


--
Chuck Lever



