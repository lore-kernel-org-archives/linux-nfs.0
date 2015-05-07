Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbbEGUYd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 16:24:33 -0400
Message-ID: <554BC9F3.6020005@RedHat.com>
Date: Thu, 07 May 2015 16:24:19 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Thorsten Kukuk <kukuk@suse.de>
CC: Mike Frysinger <vapier@gentoo.org>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: [PATCH V2] Fix Build w/gssapi disabled
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org> <20150507115248.GA20243@suse.de> <554B86E2.8090908@RedHat.com> <20150507163326.GA6156@suse.de> <554B98E9.4040601@RedHat.com> <20150507181206.GA7810@suse.de> <554BC53C.5080807@RedHat.com> <554BC730.3000004@RedHat.com>
In-Reply-To: <554BC730.3000004@RedHat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This version seems to work now.

I wonder if this warrants a 0.3.1 release...

How do other library deal with API breakage?   

steved.
