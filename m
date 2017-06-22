Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gws07.hcl.com ([192.8.186.130]:14692 "EHLO GWS07.hcl.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753818AbdFVTEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Jun 2017 15:04:34 -0400
From: Brian Cowan <brian.cowan@hcl.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: 2 potentially stupid questions.
Date: Thu, 22 Jun 2017 18:51:05 +0000
Message-ID: <PS1PR04MB16925A39FB7C41D10CDFAE54FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
References: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
In-Reply-To: <PS1PR04MB1692ED9241F275897AC5F320FEDB0@PS1PR04MB1692.apcprd04.prod.outlook.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

I need to do some stress testing the product I support accessing storage over NFS v4.1 and compare the performance with NFSv3 (with its lovely NLM) and NFSv4 (with its fun integral client lock retry interval). This brings me to the 2 potentially stupid questions:

1) Is there a "gold standard" server? I know that the "de facto standard" is usually Solaris, but I'm looking for a something like a "least common denominator" NFS v4.1 server implementation. I'm trying to avoid "test this client [red hat 7.4 snapshot 3 ATM] with this half-dozen servers and see what happens on each" kind of tests since that seriously muddies the waters. Especially since I will need to test Ubuntu 14/16, SuSE 11 & 12, CentOS, etc., clients.

2) Is there a simple way to set the maximum NFS version on a PER-EXPORT basis on a single server. The "exports" man page is mum on the subject. I'm getting around this by explicitly mounting my "control" (NFSv3) export as NFSv3, but if there is a way to set a max protocol version on the EXPORT, that would simplify testing since I could just use autofs. Yes, I can enable use of, and then tweak, /etc/auto.net to do this, but I'm trying to do the fiddling in just one place as I know that I'll need to do these tests for other Linux distros. Especially since it seems autofs is somewhat twitchy when using /net mounts (sometimes -hosts works, sometimes it doesn't, sometimes using the auto.net file works, other times it doesn't).

Thanks for any hints.

Bruce, this is the issue where lock contention on NFSv4 would cause lockers on the same machine to go asleep for integral #'s of seconds. 

Brian Cowan.


::DISCLAIMER::
----------------------------------------------------------------------------------------------------------------------------------------------------

The contents of this e-mail and any attachment(s) are confidential and intended for the named recipient(s) only.
E-mail transmission is not guaranteed to be secure or error-free as information could be intercepted, corrupted,
lost, destroyed, arrive late or incomplete, or may contain viruses in transmission. The e mail and its contents
(with or without referred errors) shall therefore not attach any liability on the originator or HCL or its affiliates.
Views or opinions, if any, presented in this email are solely those of the author and may not necessarily reflect the
views or opinions of HCL or its affiliates. Any form of reproduction, dissemination, copying, disclosure, modification,
distribution and / or publication of this message without the prior written consent of authorized representative of
HCL is strictly prohibited. If you have received this email in error please delete it and notify the sender immediately.
Before opening any email and/or attachments, please check them for viruses and other defects.

----------------------------------------------------------------------------------------------------------------------------------------------------

