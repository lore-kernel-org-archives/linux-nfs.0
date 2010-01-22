Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:26369 "EHLO esri3.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754011Ab0AVUQn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 15:16:43 -0500
Received: from leoray.esri.com (leoray.esri.com [10.27.102.12])
	by esri3.esri.com (8.11.7p3+Sun/8.11.7) with ESMTP id o0MKGc625506
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 12:16:43 -0800 (PST)
Received: from leoray.esri.com (leoray.esri.com [127.0.0.1])
	by leoray.esri.com (8.14.3/8.14.3) with ESMTP id o0MKGc7s026342
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 12:16:38 -0800
Received: (from ray5147@localhost)
	by leoray.esri.com (8.14.3/8.14.3/Submit) id o0MKGcxu026341
	for linux-nfs@vger.kernel.org; Fri, 22 Jan 2010 12:16:38 -0800
Date: Fri, 22 Jan 2010 12:16:38 -0800
From: Ray Van Dolson <rvandolson@esri.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Source address in server callbacks fix...
Message-ID: <20100122201638.GA26316@esri.com>
References: <20100122200525.GA26072@esri.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100122200525.GA26072@esri.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 22, 2010 at 12:05:25PM -0800, Ray Van Dolson wrote:
> We're being bitten by the source address in server callbacks
> issue[1][2].
> 
> The post above[1], mentions kernel fixes for this.  I'm having a hard
> time locating this commit so I can determine if it has been backported
> to the RHEL5 kernel yet.
> 
> Can anyone point me in the right direction?

Spoke too soon.  This[1] appears to be it.  Don't know if there are
subsequent patches that improve upon this or not...

Ray

[1] http://git.linux-nfs.org/?p=bfields/linux.git;a=commit;h=16cefa8c3863721fd40445a1b34dea18cd16ccfe
