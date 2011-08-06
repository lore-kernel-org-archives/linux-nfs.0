Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753941Ab1HFBkM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Aug 2011 21:40:12 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <20028.39798.213403.685504@regina.usersys.redhat.com>
Date: Sat, 6 Aug 2011 11:40:06 +1000
From: Max Matveev <makc@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
In-Reply-To: <20110805124015.GA16926@merit.edu>
References: <20110805021903.C84608198734@regina.usersys.redhat.com>
	<20110805124015.GA16926@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 5 Aug 2011 08:40:15 -0400, Jim Rees wrote:

 rees> Max Matveev wrote:
 rees>   NFS/TCP does linear backoff then retransmiting - the manpage
 rees>   was mistakenly asserting the "no backoff" theory.

 rees> Actually, now that I made you change the wording, I think the original
 rees> wording was correct.  "Backoff" refers to an increase in the interval
 rees> between retries.  Since the interval is constant, there is no backoff.

The interval is increased: with timeo=10 (1 sec) the retries will be
happening and t+1, t+3, t+6 etc - see my original mail on Jul 7:

http://www.spinics.net/lists/linux-nfs/msg22425.html

If that's not a backoff then what is?

max
