Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0170.hostedemail.com ([216.40.44.170]:57200 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750788AbcGOOV1 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2016 10:21:27 -0400
Date: Fri, 15 Jul 2016 10:21:22 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix the socket autoclose regression
Message-ID: <20160715102122.47403b66@gandalf.local.home>
In-Reply-To: <1468537380-66033-1-git-send-email-trond.myklebust@primarydata.com>
References: <1468537380-66033-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Jul 2016 19:02:59 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Hi Steven
> 
> Does the following patch fix the issue you reported?

I just tested it out, and unfortunately, even with this patch, after
the disconnect, the hidden port is still there.

# while :; do if ! netstat -tapn |grep :812; then break; fi; sleep 1; done;
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     ESTABLISHED -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     ESTABLISHED -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     ESTABLISHED -            
[..]
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     ESTABLISHED -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     ESTABLISHED -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     ESTABLISHED -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     ESTABLISHED -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     TIME_WAIT   -
[..]
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:812        192.168.23.22:35050     TIME_WAIT   -                   
# unhide-tcp 
Unhide-tcp 20130526
Copyright © 2013 Yago Jesus & Patrick Gouin
License GPLv3+ : GNU GPL version 3 or later
http://www.unhide-forensics.info
Used options: 
[*]Starting TCP checking

Found Hidden port that not appears in ss: 812
[*]Starting UDP checking

Thanks,

-- Steve


> 
> Cheers
>   Trond
> 
> Trond Myklebust (1):
>   SUNRPC: Force a close when a socket keepalive timeout occurs
> 
>  net/sunrpc/xprtsock.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 

