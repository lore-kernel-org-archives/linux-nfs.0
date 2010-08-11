From: Antoine Samson <antoine.samson-UTvucLA2meAAvxtiuMwx3w@public.gmane.org>
Subject: NFSD process amount
Date: Wed, 11 Aug 2010 15:39:54 +0200
Message-ID: <4C62A82A.8040206@etiam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from publicsmtp.etiam.com ([217.109.110.150]:37874 "EHLO
	mailserver.etiam.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab0HKNrD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Aug 2010 09:47:03 -0400
Received: from [192.168.0.16] (unknown [172.16.0.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailserver.etiam.com (Postfix) with ESMTPSA id 43CA0580F8
	for <linux-nfs@vger.kernel.org>; Wed, 11 Aug 2010 15:39:55 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear all,

I've got a NFS clustered service with NFSDCOUNT set to 75.
This process number is being monitored and we've found that each night 
around 4:30am, one more process appears and then disappears.
Nothing specific is being shown on system logs

We have no specific crontab job at this time except default logrotate.
I've suspected this could be due to the SIGHUP of logrotate but could 
not reproduce on my lab. Anyway, SIGHUP should not fork a new child 
process...

Does anyone would have an idea?
(please note that I cannot disable logrotate on our production cluster 
as a matter of test)

Thank you,

Antoine
