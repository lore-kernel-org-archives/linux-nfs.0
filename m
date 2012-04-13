Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:49851 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821Ab2DMPGU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Apr 2012 11:06:20 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 13 Apr 2012 11:06:18 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9BE786E8060
	for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 11:05:55 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3DF5aqV2064606
	for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 11:05:37 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3DF5URE007699
	for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 09:05:31 -0600
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q3DF5Rwr006341
	for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 09:05:27 -0600
Date: Fri, 13 Apr 2012 10:05:18 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120413150518.GA1987@us.ibm.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton [jlayton@redhat.com] wrote:
> 1) should we retry these calls on all filesystems, or attempt to have
> them "opt-in" in some fashion? This patch adds a flag for that, but
> we could just treat all filesystems the same way.

I don't know any cases where a retry on ESTALE would hurt. I would say
retry on all file systems the same way.

> 2) How many times should we retry on an ESTALE error? Once?
> Indefinitely? Some amount in between? Retrying once would probably
> fix the bulk of the real world problems with this, but there will
> still be cases where that's not sufficient.

As you say 1 retry should work in most cases. Indefinitely doesn't make
sense, I would rather let my application fail! How about 3 retries (3 is
a nice number! :-) )

Regards, Malahal.

