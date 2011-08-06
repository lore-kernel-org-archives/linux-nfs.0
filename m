Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:33266 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249Ab1HFMn6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 08:43:58 -0400
Date: Sat, 6 Aug 2011 08:43:56 -0400
From: Jim Rees <rees@umich.edu>
To: Max Matveev <makc@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
Message-ID: <20110806124356.GB20169@merit.edu>
References: <20110805021903.C84608198734@regina.usersys.redhat.com>
 <20110805124015.GA16926@merit.edu>
 <20028.39798.213403.685504@regina.usersys.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20028.39798.213403.685504@regina.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Max Matveev wrote:

  The interval is increased: with timeo=10 (1 sec) the retries will be
  happening and t+1, t+3, t+6 etc - see my original mail on Jul 7:
  
  http://www.spinics.net/lists/linux-nfs/msg22425.html
  
  If that's not a backoff then what is?

You're right.  Sorry I misunderstood.  Re-reading what you wrote I'm not
sure it could be made any clearer.  Maybe change "timeout is increased" to
"timeout interval is increased."  But I'd be happy with it as-is.
