From: "Smets, Jan (Jan)" <jan.smets@alcatel-lucent.com>
Subject: NFS Server cache
Date: Fri, 25 Jun 2010 00:57:05 +0200
Message-ID: <14C7F4F06DB5814AB0DE29716C4F6D670B7030B4@FRMRSSXCHMBSB1.dc-m.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smail6.alcatel.fr ([64.208.49.42]:37500 "EHLO smail6.alcatel.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266Ab0FXW5J convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jun 2010 18:57:09 -0400
Received: from FRMRSSXCHHUB03.dc-m.alcatel-lucent.com (FRMRSSXCHHUB03.dc-m.alcatel-lucent.com [135.120.45.63])
	by smail6.alcatel.fr (8.14.3/8.14.3/ICT) with ESMTP id o5OMv6Ko023583
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jun 2010 00:57:06 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi list

If I understood correctly, the main memory is used for caching NFS server data. Can I get more information on this? Statistics?

Is it possible to use a sort of fs-cache on the server? Thus using a SSD drive as cache for example. (at first sight fs-cache can only be used on the client side..)

And maybe not so related: can I do data de-duplication? (within te cache? .. But I guess the FS should do that, but I could not find any capable of doing this on Linux.)

Thanks!

- Jan
