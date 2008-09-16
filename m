From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: [PATCH 0/2] NFSV4 Ipv6 server support
Date: Tue, 16 Sep 2008 11:28:54 +0200
Message-ID: <48CF7C56.7070708@bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000203020107030108080900"
Cc: linux-nfs@vger.kernel.org, nfsv4 <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:44946 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbYIPJek (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Sep 2008 05:34:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000203020107030108080900
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------000203020107030108080900
Content-Type: text/plain;
 name="patch0_nfsv4ipv6server"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch0_nfsv4ipv6server"

Hi Bruce-

Here are a couple of fixes for the code that makes IPV6 server support over RPC 
services with the local rpcbind daemon:
. The first is a patch which gathers the Chuck Lever's patches serie to Register
 kernel RPC services via rpcbind v4
. The second is a patch of mine which completes the ipv6 server implementation 
  I have tested on 2.6.27-rc3 kernel.

I have used a nfs-utils prototype package based on nfs-utils.1.1.2 to get the
 ipv6 adapted mount ,nfsd, mountd and exportfs utils.
The package will be available on Bull site (http://nfsv4.bullopensource.org/) in the next few days

---

Aime Le Rouzic (2):
	SUNRPC: Register kernel RPC services via rpcbind v4
	NFSV4 IPV6: Ipv6 server support addings over rpcbind 




-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 

--------------000203020107030108080900--
