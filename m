From: Leif Nixon <nixon@nsc.liu.se>
Subject: Re: Cache invalidation bug in NFS v3 - trivially reproducible
Date: Fri, 14 Oct 2005 15:34:25 +0200
Message-ID: <m364s0mdcu.fsf@nammatj.nsc.liu.se>
References: <m33bn8bet4.fsf@nammatj.nsc.liu.se>
	<1129242855.8435.32.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Oestergaard <jakob@unthought.net>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750745AbVJNNed@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1129242855.8435.32.camel@lade.trondhjem.org> (Trond
 Myklebust's message of "Thu, 13 Oct 2005 18:34:14 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> Does the attached patch help?

Yes, it does indeed seem to solve the problem.

Thanks!

-- 
Leif Nixon                       -            Systems expert
------------------------------------------------------------
National Supercomputer Centre    -      Linkoping University
------------------------------------------------------------
