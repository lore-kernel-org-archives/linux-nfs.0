From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: Re: lockd oopses continue with 2.6.16.1
Date: Thu, 13 Apr 2006 13:29:43 -0400
Message-ID: <20060413172943.GF12686@tau.solarneutrino.net>
References: <20060412172028.GA12637@tau.solarneutrino.net> <1144942392.25298.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750842AbWDMR3r@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1144942392.25298.6.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Apr 13, 2006 at 11:33:12AM -0400, Trond Myklebust wrote:
> Does the following patch (applies on top of 2.6.17-rc1) help?
> 
> http://client.linux-nfs.org/Linux-2.6.x/2.6.17-rc1/linux-2.6.17-010-fix_nlm_reclaim_races.dif

Thanks, I'll try this out.  It will probably be at least a couple of
weeks before I can report on whether it works.

Cheers,
-ryan
