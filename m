Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:46448 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789Ab2GRXE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jul 2012 19:04:56 -0400
Date: Wed, 18 Jul 2012 19:04:45 -0400
From: Jim Rees <rees@umich.edu>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Trond.Myklebust@netapp.com,
        davem@davemloft.net, davej@redhat.com, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values
 of flush
Message-ID: <20120718230445.GA6561@umich.edu>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com>
 <20120718173913.GA1298@fieldses.org>
 <20120718200049.GA17964@umich.edu>
 <20120718210825.GA3145@fieldses.org>
 <50072BA7.6070205@gmail.com>
 <50072DEE.2000205@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50072DEE.2000205@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sasha Levin wrote:

  > Learning from what happened in this specific case, there are actually 2 issues here:
  > 
  >  - Array size was constant and too small, which is solved by the patch above.
  >  - We were blindly trying to sprintf() into that array, this issue may pop back up if someone decides to change the format string forgetting to modify the array declaration.
  > 

The original patch changed the sprintf to snprintf, and that still seems
like a good idea.
