From: Ray Van Dolson <rvandolson-v48TKWNzwFw@public.gmane.org>
Subject: pseudo root status?
Date: Fri, 19 Feb 2010 11:00:49 -0800
Message-ID: <20100219190049.GA32080@esri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:46713 "EHLO Vail.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521Ab0BSTBG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Feb 2010 14:01:06 -0500
Received: from leoray.esri.com (leoray.esri.com [10.27.102.12])
	by Vail.esri.com (8.13.7+Sun/8.13.7) with ESMTP id o1JJ0n8R005495
	for <linux-nfs@vger.kernel.org>; Fri, 19 Feb 2010 11:00:49 -0800 (PST)
Received: from leoray.esri.com (leoray.esri.com [127.0.0.1])
	by leoray.esri.com (8.14.3/8.14.3) with ESMTP id o1JJ0nBv032279
	for <linux-nfs@vger.kernel.org>; Fri, 19 Feb 2010 11:00:49 -0800
Received: (from ray5147@localhost)
	by leoray.esri.com (8.14.3/8.14.3/Submit) id o1JJ0nBC032278
	for linux-nfs@vger.kernel.org; Fri, 19 Feb 2010 11:00:49 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

What is the status of the dynamic pseudo root support in nfs-utils?  I
see in commit b25694320f2bdd79de82f2003209b8229eafff36 mention of a way
to define an export with a pseudo root, but I cloned Steve's latest git
tree of nfs-utils and am not seeing much about pseudo root support at
all.

The 1.2.2 announcement message seems to include a blurb about it --
does this version have what I need?

Ray
