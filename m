Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19808 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605AbcEEQEj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 12:04:39 -0400
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u45G4cu9003502
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2016 16:04:38 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id u45G4cEB018352
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2016 16:04:38 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id u45G4ZPF019714
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2016 16:04:36 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Configuring NFSv4.0 Kerberos on a multi-homed Linux NFS server
Message-Id: <DB5B2D02-412E-46AD-9F0A-7EBA4EB0C0B0@oracle.com>
Date: Thu, 5 May 2016 12:04:34 -0400
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I have a Linux NFS server with two IP addresses:

192.168.1.55: klimt.home
10.0.0.5: klimt-ib.home

The server's keytab lists three principals:

host/klimt.home@HOME.EXAMPLE.NET
nfs/klimt.home@HOME.EXAMPLE.NET
nfs/klimt-ib.home@HOME.EXAMPLE.NET

When I mount with this:

  vers=4.0,proto=tcp,sec=sys klimt:/export

I get krb5i for lease management, and sys for data traffic.
Callback traffic from the server uses krb5i. All well and
good.

When I mount with this:

  vers=4.0,proto=tcp,sec=sys klimt-ib:/export

I get krb5i for lease management and sys for data traffic
as before, and callback traffic attempts to use krb5i.
But the client rejects all CB_COMPOUND operations because
the callback principal does not match the clp.

Looks like the server always uses the nfs/klimt service
principal for callback traffic? Is there a way to config
the server to use the principal that matches the
interface? Or is there something else going on?

--
Chuck Lever



