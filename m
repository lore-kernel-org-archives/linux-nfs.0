Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935938Ab3BOPqB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 10:46:01 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r1FFk1nc015399
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2013 10:46:01 -0500
Received: from smallhat.bos.devel.redhat.com (vpn-63-86.rdu2.redhat.com [10.10.63.86])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r1FFk0TL000981
	for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2013 10:46:00 -0500
Message-ID: <511E5838.2020103@RedHat.com>
Date: Fri, 15 Feb 2013 10:46:00 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: V4 unmount causes a GETATTR
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I have not tracked down as to the exact reason, 
but it appears umount of v4 file system cause the
directory to be revalidating causing the  GETATTR. 

Is this revalidation really necessary on an unmount? 

tia,

steved. 
