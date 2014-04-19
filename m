Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:56395 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbaDSL5d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Apr 2014 07:57:33 -0400
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 702F220B94
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2014 07:57:31 -0400 (EDT)
Received: from [192.168.1.3] (unknown [118.209.253.82])
	by mail.messagingengine.com (Postfix) with ESMTPA id B391B680116
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2014 07:57:30 -0400 (EDT)
Message-ID: <535264A3.9030202@fastmail.com.au>
Date: Sat, 19 Apr 2014 21:57:23 +1000
From: Allan Duncan <amd1234@fastmail.com.au>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfs-utils bug report (and fix)
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 1.3.0 release added a bug with the change to the 
utils/statd/start-statd script, at least on fedora 20.

The addition of a call to systemctl fails because it is in /usr/bin
The (trivial) fix is to add this to the PATH line above the call.

Anyway, thanks for the code.
