Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0214.hostedemail.com ([216.40.44.214]:47458 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752280AbcGAWjQ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 18:39:16 -0400
Date: Fri, 1 Jul 2016 18:39:12 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Jeff Layton" <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>,
        "Torvalds Linus" <torvalds@linux-foundation.org>
Subject: Re: Revert: SUNRPC: xs_sock_mark_closed() does not need to trigger
 socket autoclose
Message-ID: <20160701183912.1f9d376b@gandalf.local.home>
In-Reply-To: <0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
References: <20160701172401.3ba89015@gandalf.local.home>
	<0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Jul 2016 22:34:02 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:


> NACK. This ocde was removed on purpose because it is dangerous to
> have the TCP state change callbacks queue up a new close(). The
> connect code sometimes has to close sockets that are misbehaving, and
> so we’ve seen races whereby the old socket closes and triggers an
> autoclose for the new socket while it is connecting.

OK fine. But can we please come up with a solution to get rid of the
hidden port issue. It's very annoying that I get a message from
rkhunter ever morning telling me "Please inspect this machine, because
it may be infected."

-- Steve
