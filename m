From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Why NFS server does not pass lock requests via VFS lock() op?
Date: 10 Oct 2002 02:28:09 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shs8z1716jq.fsf@charged.uio.no>
References: <OFAB5FE3E3.3D571A56-ON87256C4D.008352AE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	linux-kernel-owner@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Juan Gomez <juang@us.ibm.com>
In-Reply-To: <OFAB5FE3E3.3D571A56-ON87256C4D.008352AE@us.ibm.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Juan Gomez <juang@us.ibm.com> writes:

     > Oh ok. Well can we resuscitate this patch? The AFS NAS head
     > example is a good reason to do this.  If you need any help

If you do, make sure that you get the latest patch from Brian and
*NOT* the one that was in earlier versions of the -ac tree. The
latter screws lockd quite royally...

Cheers,
  Trond
