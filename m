Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40596 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030204Ab2HIOah (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 10:30:37 -0400
Received: by ggdk6 with SMTP id k6so486139ggd.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 07:30:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 9 Aug 2012 22:30:16 +0800
Message-ID: <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>,
        Fred Isaman <Fred.Isaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 4:21 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> Ever since commit 0a57cdac3f (NFSv4.1 send layoutreturn to fence
> disconnected data server) we've been sending layoutreturn calls
> while there is potentially still outstanding I/O to the data
> servers. The reason we do this is to avoid races between replayed
> writes to the MDS and the original writes to the DS.
>
> When this happens, the BUG_ON() in nfs4_layoutreturn_done can
> be triggered because it assumes that we would never call
> layoutreturn without knowing that all I/O to the DS is
> finished. The fix is to remove the BUG_ON() now that the
> assumptions behind the test are obsolete.
>
Isn't MDS supposed to recall the layout if races are possible between
outstanding write-to-DS and write-through-MDS?

And it causes data corruption for blocklayout if client returns layout
while there is in-flight disk IO...

-- 
Thanks,
Tao
