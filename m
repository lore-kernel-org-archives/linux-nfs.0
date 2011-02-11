Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:44470 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127Ab1BKM11 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 07:27:27 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.72)
	(envelope-from <wferi@niif.hu>)
	id 1Pns5u-00079m-70
	for linux-nfs@vger.kernel.org; Fri, 11 Feb 2011 13:27:26 +0100
From: Ferenc Wagner <wferi@niif.hu>
To: linux-nfs@vger.kernel.org
Subject: Seemingly inconsistent directory state under NFSv4
Date: Fri, 11 Feb 2011 13:27:26 +0100
Message-ID: <87sjvuiwnl.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

In our somewhat mixed NFSv4 setup (Linux 2.6.32 Debian squeeze server, a
2.6.26 and a 2.6.32 Debian lenny client) we sometimes experience the
following: removing a file on the 2.6.26 client makes that file
disappear from the directory listing of the 2.6.32 client, but the file
itself remains accessible by its old -- now nonexistent -- name there.
Is such a confusing state expected, or is this the manifestation of some
bug?
-- 
Thanks,
Feri.
