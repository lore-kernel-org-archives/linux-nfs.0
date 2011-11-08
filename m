Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752163Ab1KHICA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 03:02:00 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <20152.57839.274405.760444@regina.usersys.redhat.com>
Date: Tue, 8 Nov 2011 19:01:51 +1100
From: Max Matveev <makc@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: rpcbind -h
In-Reply-To: <20111107172131.GA1008@umich.edu>
References: <20111106155844.GA1790@umich.edu>
	<3096DDEC-48D3-423A-B674-160B8DA59DE2@oracle.com>
	<20111107172131.GA1008@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Nov 2011 12:21:31 -0500, Jim Rees wrote:

 rees> Chuck Lever wrote:
 rees>   On Nov 6, 2011, at 10:58 AM, Jim Rees wrote:
  
 >> Is there some good reason why the rpcbind '-h' option (bind to given
 >> address) applies only to the udp listening socket and not to the tcp socket?
  
 rees>   Yes.  See the mail archives.  I believe we've discussed this
 rees>   thoroughly within the past six months to a year.  If there's
 rees>   any bug here, it's that "-h" is not well documented.

 rees> It's documented well enough but I'm still in the dark about the
 rees> reason.  I

Chuck's quote from the manpage reminded me - -h was used to work
around the address selection: if server has more then one address the
reply may use any of them. Some clients don't like it.

This issue should go away after

commit 74ef3df0236c55185225c62fba34953f2582da72
Author: Olaf Kirch <okir@suse.de>
Date:   Wed Mar 2 10:09:24 2011 -0500

was added to libtirpc.

 rees> As I said before, I was hoping for the equivalent of "portmap
 rees> -l".  I was ready to code up a patch of some kind but now have
 rees> a workaround (mount with nolock and don't run rpcbind at all).

iptables is another option.

max

