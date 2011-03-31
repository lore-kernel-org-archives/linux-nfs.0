Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65410.mail.ac4.yahoo.com ([76.13.9.30]:45147 "HELO
	web65410.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759434Ab1CaWa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2011 18:30:57 -0400
Message-ID: <457901.56654.qm@web65410.mail.ac4.yahoo.com>
Date: Thu, 31 Mar 2011 15:24:15 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: readdirplus/getattr
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I've been trying to get my Linux NFS clients to be a little snappier about listing large directories from heavily-loaded servers.  I found the following fascinating behaviour (this is with 2.6.31.14-0.6-desktop, x86_64, from openSUSE 11.3, Solaris Express 11 NFS server):

With "ls -l --color=none" on a directory with 2500 files:

             |      rdirplus   |    nordirplus   |
             |1st  |2nd  |1st  |1st  |2nd  |1st  |
             |run  |run  |run  |run  |run  |run  |
             |light|light|heavy|light|light|heavy|
             |load |load |load |load |load |load |
--------------------------------------------------
readdir      |   0 |   0 |   0 |  25 |   0 |  25 |
readdirplus  | 209 |   0 | 276 |   0 |   0 |   0 |
lookup       |  16 |   0 |  10 |2316 |   0 |2473 |
getattr      |   1 |2501 |2452 |   1 |2465 |   1 |

The most interesting case is with rdirplus specified as a mount option to a heavily loaded server.  The NFS client keeps switching back and forth between readdirplus and getattr:

 ~10 seconds doing ~70 readdirplus calls, followed by
 ~150 seconds doing ~800 gettattr calls, followed by
 ~12 seconds doing ~70 readdirplus calls, followed by
 ~200 seconds doing ~800 gettattr calls, followed by
 ~20 seconds doing ~130 readdirplus calls, followed by
 ~220 seconds doing ~800 gettattr calls

All the calls appear to get reasonably prompt replies (never more than a second or so), which makes me wonder why it keeps switching back and forth between the strategies.  (Especially since I've specified rdirplus as a mount option.)

Is it supposed to do that?

I'd really like to see how it does with readdirplus ~only~, no getattr calls, since it's spending only 40 seconds in total on readdirplus calls compared to 570 seconds in total on (redundant, I think, based on the lightly-loaded case) getattr calls.

It'd also be nice to be able to force readdirplus calls instead of getattr calls for second and subsequent listings of a directory.

I saw a recent thread talking about readdirplus changes in 2.6.37, so I'll give that a try when I get a chance to see how it behaves.

Andrew


