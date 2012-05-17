Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:53453 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264Ab2EQRn1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 13:43:27 -0400
Received: from hop04-l1d11-si01.isus.emc.com (HOP04-L1D11-SI01.isus.emc.com [10.254.111.54])
	by mexforward.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id q4HHhLlB004283
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 13:43:25 -0400
Received: from mailhub.lss.emc.com (mailhub.lss.emc.com [10.254.221.145]) by hop04-l1d11-si01.isus.emc.com (RSA Interceptor) for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 13:43:08 -0400
Received: from usensfaibishl1e.corp.emc.com (AUTGZHUR1L2C.corp.emc.com [10.13.34.41])
	by mailhub.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id q4HHh7Z5019897
	for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 13:43:07 -0400
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
In-Reply-To: <4F4E8F3A.8070708@RedHat.com>
References: <4F4603EC.9030404@redhat.com> <4F4E8F3A.8070708@RedHat.com>
Subject: pNFS block performance evaluation (sorry for the wrong subject title)
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 17 May 2012 13:43:02 -0400
MIME-Version: 1.0
From: "Sorin Faibish" <sfaibish@emc.com>
Message-ID: <op.wegrh0gprwwil4@usensfaibishl1e.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Team,

These are some preliminary results with pNFS block. They look very
promising both performance and scalability. They uncovered some
instability but mainly due to HW issues; no SW issues. These results are
our prove that the latest pNFS block code is stable and performing
reasonably well.

Single client pNFS performance was 86MB/sec write performance for
reference. Thank you very much for your patience and support



We’ve finished the testing and analysis of pNFS vs. MPFS.  It took much
longer than expected due to several stability issues uncovered on both the
client and the server.  Some of the issues occurred during read testing,
which had never been a focus of previous testing efforts.  Anyway, please
find the results below.  To help with the below interpretation, please
reference the following key:

SW8xN-MPFS              Sequential Write 8 clients by N threads using MPFS
(special build using latest kernel on Fedora 15)
SR8xN-MPFS              Sequential Read 8 clients by N threads using MPFS
(special build on Fedora 15)
SW8xN-pNFS              Sequential Write 8 clients by N threads using pNFS
(on Fedora 15)
SR8xN-pNFS              Sequential Read 8 clients by N threads using pNFS
(on Fedora 15)
SW8xN-pNFS2             Sequential Write 8 clients by N threads using pNFS
(on Fedora 15)
SR8xN-pNFS2             Sequential Read 8 clients by N threads using pNFS
(on Fedora 15)
SR8xN-pNFS3             Sequential Read 8 clients by N threads using pNFS
(on Fedora 15)
SW8xN-MPFS2             Sequential Write 8 clients by N threads using MPFS
SR8xN-MPFS2             Sequential Read 8 clients by N threads using MPFS

I think/hope the rest is self-explanatory based on labels, etc.  To
summarize:


	pNFS2	pNFS4vs.MPFS
SW8x1	653121.85	-8%
SW8x2	835101.05	-10%
SW8x3	846188.63	-8%
SW8x4	852617.66	-6%
SR8x1	674129.88	43%
SR8x2	634800.33	34%
SR8x3	629843.20	28%
SR8x4	577197.70	19%

Let me know what you think or if you have any questions.  I’m moving on to
other projects that I’ve committed to and am currently behind on.

-- 
--
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Fast Data Group - Office of CTO
                             EMC2
where information lives

Phone: 508-249-5745
Mobile: 617-510-0422
email: sfaibish@emc.com
