From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Re: Non-blocking lock requests during the grace period ===> unlock
 during grace period?
Date: Thu, 21 Nov 2002 00:06:34 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15836.5498.109808.440533@charged.uio.no>
References: <OF20A29A8A.9BDEB891-ON87256C77.006712BE@us.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Kupfer <kupfer@athyra.eng.sun.com>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Juan Gomez <juang@us.ibm.com>
In-Reply-To: <OF20A29A8A.9BDEB891-ON87256C77.006712BE@us.ibm.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Juan Gomez <juang@us.ibm.com> writes:

     > OK, fair enough. I think I will withdraw my request to 'fix'
     > this. If Solaris and other falvors of Unix (i.e. Aix) behave
     > this way I think it would not be good to change just Linux.
     > The other minor change I proposed earlier was that we allow
     > unlock operations during the grace period, and this will be
     > useful in clustered NAS heads.  What do you guys think about
     > such a change?

Until the server knows that the client has finished re-establishing
all state information, it should not accept any requests to modify
that state. Unfortunately, the only way it has of knowing that the
client is done is the grace period expiration...

Cheers,
  Trond
