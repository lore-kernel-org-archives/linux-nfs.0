Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:60825 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267Ab1HEMkU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Aug 2011 08:40:20 -0400
Date: Fri, 5 Aug 2011 08:40:15 -0400
From: Jim Rees <rees@umich.edu>
To: Max Matveev <makc@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
Message-ID: <20110805124015.GA16926@merit.edu>
References: <20110805021903.C84608198734@regina.usersys.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110805021903.C84608198734@regina.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Max Matveev wrote:

  NFS/TCP does linear backoff then retransmiting - the manpage
  was mistakenly asserting the "no backoff" theory.

Actually, now that I made you change the wording, I think the original
wording was correct.  "Backoff" refers to an increase in the interval
between retries.  Since the interval is constant, there is no backoff.

I could be wrong.  I think the term "backoff" was first used this way in
ALOHA.  I've got some papers around here somewhere and can check.

But maybe the best thing would be to remove any reference to backoff, and
talk about retry instead.
