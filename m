From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Thu, 11 Sep 2008 10:19:08 -0700
Message-ID: <20080911171908.GE12037@merfinllc.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com> <20080908190212.GF28123@merfinllc.com> <76bd70e30809081415h6b55a8dfl8171634c576ac946@mail.gmail.com> <20080909194644.GI5290@merfinllc.com> <8BFB4AE0-3EF1-41FA-A13B-27E380A79950@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:36396 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752230AbYIKRTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2008 13:19:09 -0400
In-Reply-To: <8BFB4AE0-3EF1-41FA-A13B-27E380A79950@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Sep 11 12:55 PM, Chuck Lever wrote:
> A more thorough review of the NFS write and flush logic that exists in
> 2.6.27 is needed if we choose to recognize this issue as a real
> problem.

Yep.  

Sorry.  I didn't mean we should revert the hunk.  I was just trying to
help identify the cause of the new behavior.

I think this is a real problem albeit not a "serious" one.  Network
file-systems usually try to avoid readers seeing blocks of zeros in
files, especially in this simple writer/reader case.

It wouldn't be bad if the file is written out of order occasionally, but
we see this constantly now.

We cannot write/read log files to NFS mounts reliably any more.  That
seems like a valid use case which no longer works?

Anyway, thanks for your time!

				=a=



-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org
