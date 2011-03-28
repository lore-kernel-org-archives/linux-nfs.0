Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from keetweej.vanheusden.com ([83.163.219.98]:45610 "EHLO
	keetweej.vanheusden.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442Ab1C1L64 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 07:58:56 -0400
Received: from belle.intranet.vanheusden.com (belle.intranet.vanheusden.com [192.168.64.100])
	by keetweej.vanheusden.com (Postfix) with ESMTP id 2A95C160EA2
	for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 13:50:48 +0200 (CEST)
Date: Mon, 28 Mar 2011 13:50:47 +0200
From: folkert <folkert@vanheusden.com>
To: linux-nfs@vger.kernel.org
Subject: error message
Message-ID: <20110328115046.GH3997@belle.intranet.vanheusden.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

When a nfs-mount fails because portmapper is not running on the other
end, mount.nfs says "connection refused". Now it is not always directly
clear what is refusing connection. So maybe one can change the message
to "connection to portmapper on server refused".


Folkert van Heusden

-- 
Nagios user? Check out CoffeeSaint - the versatile Nagios status
viewer! http://www.vanheusden.com/java/CoffeeSaint/
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com
