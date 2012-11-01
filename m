Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sr-smtp.usish.com ([210.5.144.203]:47907 "EHLO
	sr-smtp.usish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760746Ab2KANgE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2012 09:36:04 -0400
Received: from outbound.usish.com (unknown [192.168.40.103])
	by sr-smtp.usish.com (Postfix) with ESMTP id B777877821C
	for <linux-nfs@vger.kernel.org>; Thu,  1 Nov 2012 16:26:27 +0800 (CST)
Received: from outbound.usish.com (outbound.usish.com [127.0.0.1])
	by postfix.imss70 (Postfix) with ESMTP id 61EF74280A8
	for <linux-nfs@vger.kernel.org>; Thu,  1 Nov 2012 16:58:47 +0800 (CST)
Received: from [192.168.58.59] (unknown [192.168.58.59])
	by outbound.usish.com (Postfix) with ESMTP id 3FF7E428041
	for <linux-nfs@vger.kernel.org>; Thu,  1 Nov 2012 16:58:47 +0800 (CST)
Subject: hang problem when umount a nfs point
From: dahai_tian <dahai_tian@usish.com>
Reply-To: dahai_tian@usish.com
To: linux-nfs@vger.kernel.org
Date: Thu, 01 Nov 2012 16:58:17 +0800
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1351760297.5369.1.camel@localhost>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all:
        I mount a local directory to a nfs server. When nfs server is
stopped
for some accidental cause, I try to umount the mount point, the umount
command will hang and 'time out' messages are continually printed in the
terminal. How can I avoid hanging in this case? BTW, This issue does not
exist when I changed nfs version from 4 to 3. 
        Look forward to your response, thanks!

