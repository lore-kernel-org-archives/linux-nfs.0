From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: O_NONBLOCK for regular files
Date: Tue, 12 Apr 2005 23:31:31 -0700
Message-ID: <1113373891.9903.7.camel@lade.trondhjem.org>
References: <405C0DC0.3E61994@melbourne.sgi.com>
	 <1113353153.1956.481.camel@hole.melbourne.sgi.com>
	 <1113371790.9903.3.camel@lade.trondhjem.org>
	 <1113372223.1956.628.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Filesystem Development List <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1113372223.1956.628.camel@hole.melbourne.sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

on den 13.04.2005 Klokka 16:03 (+1000) skreiv Greg Banks:

> Any other issues?
> 
> Greg.

Well, I'm sa bit curious as to what "iap->ia_valid |= ATTR_NO_BLOCK"
will do. AFAICS, there is nothing that actually tests for it.

Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

