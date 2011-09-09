Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:53739 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932908Ab1IIT4R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 15:56:17 -0400
Date: Fri, 9 Sep 2011 15:56:15 -0400
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: shouldn't rpc_pipe_upcall message structs be
 __attribute__((packed)) ?
Message-ID: <20110909195615.GA21276@merit.edu>
References: <20110909143605.57d54899@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110909143605.57d54899@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Layton wrote:

  The blocklayout upcall is even more scary as the width of the status
  field is not explicit:
  
  struct bl_dev_msg {
          int status;
          uint32_t major, minor;
  };

I'll take the blame for that one.  I will queue up a fix.

Making the blocklayout upcall struct packed might still be possible since
it's not officially released until 3.1, but I'm terrified of making changes
at this point in the release cycle that aren't actual bug fixes.
