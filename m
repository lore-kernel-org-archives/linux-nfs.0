From: Anders Saaby <as@cohaesio.com>
Subject: Re: NFS client bug in 2.6.8-2.6.11
Date: Tue, 8 Mar 2005 09:56:40 +0100
Message-ID: <200503080956.41086.as@cohaesio.com>
References: <422D2FDE.2090104@develer.com> <422D485F.5060709@develer.com> <422D4E5A.1050409@develer.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	lkml <linux-kernel@vger.kernel.org>,
	Neil Conway <nconway_kernel@yahoo.co.uk>,
	nfs@lists.sourceforge.net
To: Bernardo Innocenti <bernie@develer.com>
In-Reply-To: <422D4E5A.1050409@develer.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday 08 March 2005 08:03, Bernardo Innocenti wrote:
> Bernardo Innocenti wrote:
> > Trond Myklebust wrote:
> >
> > I also can't reproduce the problem on an older
> > client running 2.4.21.
>
> Well, actually I tried harder with the 2.4.21
> client and I obtained a similar effect:
>
> So, instead of ENOENT I get ESTALE on 2.4.21.
>
> May well be a server bug then.  The server is running
> 2.6.10-1.766_FC3.  Do you think I should try installing
> a vanilla kernel on the server?

We have seen lots of ESTALE's/ENOENT's when the server is running 2.6.10 
(vanilla). Don't know if this was supposed to be fixed in the 2.6.10-FC 
kernels, but vanilla 2.6.11 doesen't seem to have this bug at all.

You mention a lot of kernel versions including 2.6.11, and I can't really 
figure out whether you are talking abount the clients or the server. - 
Anyways if your server has only run with 2.6.10 - try 2.6.11.

- Apologies if I missed something obvious.

-- 
Med venlig hilsen - Best regards - Meilleures salutations

Anders Saaby
Systems Engineer
------------------------------------------------
Cohaesio A/S - Maglebjergvej 5D - DK-2800 Lyngby
Phone: +45 45 880 888 - Fax: +45 45 880 777
Mail: as@cohaesio.com - http://www.cohaesio.com
------------------------------------------------
