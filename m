From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: how to parse the 64byte NFSv3 file handle
Date: Mon, 19 May 2008 10:44:31 -0400
Message-ID: <RTPCLUEXC1-PRDRBVyM0000010c@RTPMVEXC1-PRD.hq.netapp.com>
References: <483136FC.4050208@ncic.ac.cn>
 <483140C4.3010104@panasas.com>
 <RTPCLUEXC1-PRDpAOAk000000fd@RTPMVEXC1-PRD.hq.netapp.com>
 <8762271D-9645-49DF-B218-E626F704DC96@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>,
	Benny Halevy <bhalevy@panasas.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758122AbYESOof (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 10:44:35 -0400
In-Reply-To: <8762271D-9645-49DF-B218-E626F704DC96@oracle.com>
References: <483136FC.4050208-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>
 <483140C4.3010104@panasas.com>
 <RTPCLUEXC1-PRDpAOAk000000fd-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <8762271D-9645-49DF-B218-E626F704DC96@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 10:36 AM 5/19/2008, Chuck Lever wrote:
>Also, there is a checkbox in the NFS decoder preference pane for  
>enabling wireshark to associated file handles with file names and  
>display the file names where appropriate.
>The checkbox is "Snoop FH to filename mappings".

Ooh- didn't know about that one. Cool. It can even build the entire
directory <-> FH tree to show the full pathname, if available.

http://wiki.wireshark.org/NFS_Preferences

Tom.

