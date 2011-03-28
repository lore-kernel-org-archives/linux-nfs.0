Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:33669 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab1C1N0m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 09:26:42 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.2) with ESMTP id p2SCeH5R012080
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 14:40:17 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id p2SCeHUT024284
	for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 14:40:17 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id p2SCeH0Z032211
	for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 14:40:17 +0200
Message-ID: <4D9081B1.1020205@cea.fr>
Date: Mon, 28 Mar 2011 14:40:17 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 : question on the resolution of unknown users and groups
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am in the following situation : a file belonging to the user whose 
(uid, gid) is (15678,15678) is to be exported via NFS through a client 
and / or a server than knows nothing about this user (there is no entry 
in /etc/passwd, in the yellow pages or whatever is used to maintain 
users's maps).

When using NFSv3, I see this on the client:

    # ls -ld unknown/
    drwxr-xr-x 2 15678 15678 4096 Mar 28 11:15 unknown/

When using NFSv4 (the rpc.idmapd is running on both client and server 
and is configured homogeneously) I see this:

    # ls -ld unknown/
    drwxr-xr-x 2 nobody nobody 4096 Mar 28 11:15 unknown/

With wireshark I can see that the server itself replies the string 
"nobody" as OWNER and OWNER_GROUP. I guess the libnfslibmap (used inside 
the rpc.idmapd) is not resolving (15678, 15678) and returns an error, 
making the nfsd returning nobody. The nfs-utils-lib that I use is 
1.1.5-1 (it's a F13 machine).
Is what I saw a regular behaviour ? How shoud I configure the client 
and/or the server to have the same display in NFSv4 and NFSv3 when 
querying attributes on objects belonging to an unknown user ?

    Regards

       Philippe

