From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] lockd
Date: Mon, 04 Oct 2004 20:22:34 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1096914154.22446.73.camel@lade.trondhjem.org>
References: <41617958.2020406@RedHat.com>
	 <1096912891.22446.67.camel@lade.trondhjem.org>
	 <1096913608.2788.19.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268268AbUJDSYp@vger.kernel.org>
To: arjanv@redhat.com
In-Reply-To: <1096913608.2788.19.camel@laptop.fenrus.com>
List-ID: <nfs.lists.sourceforge.net>

P=E5 m=E5 , 04/10/2004 klokka 20:13, skreiv Arjan van de Ven:

> actually this triggered because there was NO bkl... if you hold the b=
kl
> the warning doesn't trigger.....

Then the fix is downright wrong.

We *must* be holding the BKL upon entry to nlmclnt_lock(). All sorts of
other things depend on it.

Cheers,
  Trond
