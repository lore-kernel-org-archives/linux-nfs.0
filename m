From: Bernardo Innocenti <bernie@develer.com>
Subject: Re: NFS client bug in 2.6.8-2.6.11
Date: Tue, 08 Mar 2005 07:38:23 +0100
Message-ID: <422D485F.5060709@develer.com>
References: <422D2FDE.2090104@develer.com> <1110259831.11712.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: lkml <linux-kernel@vger.kernel.org>,
	Neil Conway <nconway_kernel@yahoo.co.uk>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110259831.11712.1.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:
> ty den 08.03.2005 Klokka 05:53 (+0100) skreiv Bernardo Innocenti:
> 
>>Appears to be a client bug.
> 
> Why?

Two clients started showing the problem after
being upgraded from FC2 to FC3, while the server
remained unchanged.

I also can't reproduce the problem on an older
client running 2.4.21.

I'll test with 2.6.7 as soon as I can reboot the
client I'm using right now.

-- 
  // Bernardo Innocenti - Develer S.r.l., R&D dept.
\X/  http://www.develer.com/
