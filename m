From: Sergey Bolshakov <sbolshakov-u2l5PoMzF/Uox3rIn2DAYQ@public.gmane.org>
Subject: Re:
Date: Wed, 06 Aug 2008 22:21:05 +0400
Message-ID: <m3wsiuf1im.fsf@hammer.lioka.obninsk.ru>
References: <488D718F.200@RedHat.com> <20080801131533.GN14057@debianrules.debiancolombia.org> <20080802172529.GC30454@fieldses.org> <87myjul1fk.fsf@burly.wgtn.ondioline.org> <20080803151022.GA31484@fieldses.org> <60C652E1-512E-484A-874E-01997B688505@oracle.com> <87d4ko5wlx.fsf@burly.wgtn.ondioline.org> <9692E351-7140-4AD8-99F8-C9271F54CD5F@oracle.com> <863alj9s8p.fsf@gere.msconsult.dk> <5535F9D8-CD96-4807-80B3-7FD4B3983794@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40703 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbYHFSZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Aug 2008 14:25:06 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KQnh0-0002zk-Rt
	for linux-nfs@vger.kernel.org; Wed, 06 Aug 2008 18:25:02 +0000
Received: from hammer.lioka.obninsk.ru ([195.112.124.104])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2008 18:25:02 +0000
Received: from sbolshakov by hammer.lioka.obninsk.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2008 18:25:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "Chuck" == Chuck Lever <chuck.lever@oracle.com> writes:
[skipped]

 > In addition to the debugging mentioned above, anyone encountering this  
 > regression can also try a git bisect on nfs-utils (between 1.1.2 and  
 > 1.1.3).

I've seen same thing with degraded sec=none having SUSE 9SP3
nfs-utils-1.0.6-103.23 on server side and 1.1.2-3899db6d
on client side, so 3c1bb23c seems causing problems.

-- 

