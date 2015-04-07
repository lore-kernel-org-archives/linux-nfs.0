Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp05.blacknight.com ([81.17.249.38]:37899 "EHLO
	outbound-smtp05.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750883AbbDGMF7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 08:05:59 -0400
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 97C1D98569
	for <linux-nfs@vger.kernel.org>; Tue,  7 Apr 2015 11:59:17 +0000 (UTC)
Message-ID: <5523C695.3060805@mpstor.com>
Date: Tue, 07 Apr 2015 12:59:17 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: pNFS setup documentation.
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

I'm trying to setup a pNFS cluster, but I'm unable to find any 
meaningful documentation about it.

I understand I have to setup a bunch of NFSv4.1 enabled systems as well 
as a Metadata service and a "layout agent" on the client nodes but I'm 
not able to find any infos about setting up the Metadata service or even 
the layout agent, nor am I able to find information about what version 
of the nfsutils I should use.

Is there a nice documentation that I could use somewhere (Any 
distribution is fine, I can adapt).

Thanks a lot in advance!

Regards,
Ben - MPSTOR.
