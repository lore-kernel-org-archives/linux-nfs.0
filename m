From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Sun, 13 Oct 2002 23:15:34 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021013.231534.08939486.davem@redhat.com>
References: <20020918.171431.24608688.taka@valinux.co.jp>
	<15786.23306.84580.323313@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: taka@valinux.co.jp, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, kuznet@ms2.inr.ac.ru
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: neilb@cse.unsw.edu.au
In-Reply-To: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>

   From: Neil Brown <neilb@cse.unsw.edu.au>
   Date: Mon, 14 Oct 2002 15:50:02 +1000

    Would you like to see if davem is happy with that bit first and get
    it in?  Then I will be happy to forward the nfsd specific bit.
   
Alexey is working on this, or at least he was. :-)
(Alexey this is about the UDP cork changes)

    I'm bit I'm not very sure about is the 'shadowsock' patch for having
    several xmit sockets, one per CPU.  What sort of speedup do you get
    from this?  How important is it really?
   
Personally, it seems rather essential for scalability on SMP.
