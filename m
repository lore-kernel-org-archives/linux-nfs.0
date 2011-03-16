Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.phy.duke.edu ([152.3.182.2]:38534 "EHLO mail.phy.duke.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755419Ab1CPVWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 17:22:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.phy.duke.edu (Postfix) with ESMTP id 2B5DD780CA
	for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2011 16:52:10 -0400 (EDT)
Received: from mail.phy.duke.edu ([127.0.0.1])
	by localhost (mail.phy.duke.edu [127.0.0.1]) (amavisd-new, port 10026)
	with LMTP id 6pe+a3OiHyBz for <linux-nfs@vger.kernel.org>;
	Wed, 16 Mar 2011 16:52:10 -0400 (EDT)
Received: from opus.phy.duke.edu (opus.phy.duke.edu [152.3.182.42])
	by mail.phy.duke.edu (Postfix) with ESMTP id 0ED76780C3
	for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2011 16:52:10 -0400 (EDT)
Message-ID: <4D812388.5020304@phy.duke.edu>
Date: Wed, 16 Mar 2011 16:54:32 -0400
From: Jimmy Dorff <jdorff@phy.duke.edu>
To: linux-nfs@vger.kernel.org
Subject: how to verify file delegations
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I'm a sysadmin doing some testing with NFSv4 on RHEL6/Fedora 14. How can 
I verify that file read and write delegations are occurring ? The 
"delegpurge" and "delegreturn" values are zero from nfsstat.

Thanks,
Jimmy
