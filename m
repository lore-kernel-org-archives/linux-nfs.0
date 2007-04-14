From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Subject: Re: [KJ][PATCH 03/04]use set_current_state in fs
Date: Sat, 14 Apr 2007 15:46:07 +0530
Message-ID: <20070414101607.GA16817@arun.site>
References: <20070414084956.GD14084@arun.site> <4620A13F.6060502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: kernel-janitors@lists.osdl.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	trond.myklebust@fys.uio.no
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754207AbXDNKOK@vger.kernel.org>
In-Reply-To: <4620A13F.6060502@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On 11:39 Sat 14 Apr     , Eric Dumazet wrote:
> Milind Arun Choudhary a =E9crit :
> >use set_current_state(TASK_*) instead of current->state =3D TASK_*, =
in fs/nfs
> Probably a dumb question, so please forgive me.
no.
you have a valid point

My bad :(
I should probably be enjoying my weekend outdoors..
breath some fresh air...
rather than sending such dumb patches..

ummmmmmmm
booting into  windows might help :)

> Why are you  forcing a memory barrier here, (and also on your other=20
> patches).
> Is'nt a  __set_current_state(TASK_RUNNING); appropriate ?
it is..

would resend later

Njo!!!
--=20
Milind Arun Choudhary
