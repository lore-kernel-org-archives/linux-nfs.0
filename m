From: Tom H <tom-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Subject: Jul 22 23:53:35 serverNameNX: svc: unknown version (0 for prog 100003
 nfsd)
Date: Fri, 23 Jul 2010 10:15:38 +0100
Message-ID: <4C495DBA.6090600@limepepper.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from honeysuckle.london.02.net ([87.194.255.144]:60446 "EHLO
	honeysuckle.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab0GWJPp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jul 2010 05:15:45 -0400
Received: from [192.168.1.64] (87.194.12.203) by honeysuckle.london.02.net (8.5.124.03)
        id 4C1F9BC2012922FA for linux-nfs@vger.kernel.org; Fri, 23 Jul 2010 10:15:44 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

Since last week my syslog is full of these messages;


  Jul 22 23:53:35 serverNameNX: svc: unknown version (0 for prog 100003
  nfsd)
 
<http://serverfault.com/questions/163306/jul-22-235335-servernamexxx-svc-unknown-version-0-for-prog-100003-nfsd>


I think it is since we started to monitor for rpcinfo -p serverNameNX
remotely.

Any suggestions on what I can do to either understand or suppress this
alert?

Thanks

Tom

