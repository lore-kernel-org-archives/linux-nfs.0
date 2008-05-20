From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and
  remove	signaling for shutdown
Date: Tue, 20 May 2008 09:33:11 -0400
Message-ID: <RTPCLUEXC1-PRDYwlib00000128@RTPMVEXC1-PRD.hq.netapp.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
 <18481.6416.571430.593722@notabene.brown>
 <4831F860.6050801@melbourne.sgi.com>
 <18482.4782.858347.981553@notabene.brown>
 <20080519222457.6f24daa5@tupile.poochiereds.net>
 <483238B3.4010702@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754764AbYETNdH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 09:33:07 -0400
In-Reply-To: <483238B3.4010702-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
 <18481.6416.571430.593722-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
 <4831F860.6050801-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
 <18482.4782.858347.981553-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
 <20080519222457.6f24daa5-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
 <483238B3.4010702-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 10:34 PM 5/19/2008, Greg Banks wrote:
>Practically none of nfsd runs under BKL, except the startup and shutdown
>sequences and some of the write handlers for /proc/fs/nfsd/.

Locking and NFSv4 delegations.

In my opinion, getting rid of the BKL in NFS comes down to getting
locking right. It's incredibly intertwined, and it's not NFS's fault.

Tom.

