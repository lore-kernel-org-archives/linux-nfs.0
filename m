From: Bernardo Innocenti <bernie@develer.com>
Subject: Re: NFS client bug in 2.6.8-2.6.11
Date: Tue, 08 Mar 2005 08:03:54 +0100
Message-ID: <422D4E5A.1050409@develer.com>
References: <422D2FDE.2090104@develer.com> <1110259831.11712.1.camel@lade.trondhjem.org> <422D485F.5060709@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	lkml <linux-kernel@vger.kernel.org>,
	Neil Conway <nconway_kernel@yahoo.co.uk>,
	nfs@lists.sourceforge.net
To: Bernardo Innocenti <bernie@develer.com>
In-Reply-To: <422D485F.5060709@develer.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Bernardo Innocenti wrote:
> Trond Myklebust wrote:
>
> I also can't reproduce the problem on an older
> client running 2.4.21.

Well, actually I tried harder with the 2.4.21
client and I obtained a similar effect:

 naraku:/pub/linux/distro/fedora-devel# ll
 ls: .: Stale NFS file handle
 naraku:/pub/linux/distro/fedora-devel# cd -
 /arc/linux
 naraku:/arc/linux# cd -
 /pub/linux/distro/fedora-devel
 naraku:/pub/linux/distro/fedora-devel# ll
 ... (lots of files)


So, instead of ENOENT I get ESTALE on 2.4.21.

May well be a server bug then.  The server is running
2.6.10-1.766_FC3.  Do you think I should try installing
a vanilla kernel on the server?

-- 
  // Bernardo Innocenti - Develer S.r.l., R&D dept.
\X/  http://www.develer.com/
