Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([82.195.75.110]:50765 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940Ab3FZXRq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 19:17:46 -0400
Received: from anibal by master.debian.org with local (Exim 4.80)
	(envelope-from <anibal@master.debian.org>)
	id 1Uryy9-0002Nc-43
	for linux-nfs@vger.kernel.org; Wed, 26 Jun 2013 23:17:45 +0000
Date: Wed, 26 Jun 2013 13:46:44 -0400
Message-Id: <201306261746.r5QHkicl015206@smtp.andrew.cmu.edu>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Subject: Bug report on nfs-common: nfsidmap crashes with exit status 139
From: Alexandre Rebert <alexandre@cmu.edu>
To: Anibal Monsalve Salazar <anibal@debian.org>
cc: Ben Hutchings <ben@decadent.org.uk>,
        Debian kernel team <debian-kernel@lists.debian.org>,
        Luk Claes <luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We found a crash in nfsidmap contained in the nfs-common package. You are being
contacted because your are listed as one of the maintainer of nfs-common.

We are planning to submit the bug to the Debian bug tracking system in two
weeks. We wanted to give you a heads-up, so that you some time to assess the
seriousness of the bug before it is publicly disclosed.

The bug report that will be submitted to the bug tracker is available at the
following url:

  http://www.forallsecure.com/bug-reports/557e857e10afad31f118e3534f57d3cf7645d9fd/

This email is part of a mass bug reporting campain comprising 1,182 bugs. You
might have received multiple emails from us concerning different programs. More
information about the mass bug reporting is available on the debian-devel
mailing list:

  http://lists.debian.org/debian-devel/2013/06/msg00720.html

Regards,
The Mayhem Team
Cylab, Carnegie Mellon University
