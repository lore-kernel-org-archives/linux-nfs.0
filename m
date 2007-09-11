From: Neil Brown <neilb@suse.de>
Subject: Re: [OOPS] 2.6.23-rc5 in tcp/net/nfsd
Date: Tue, 11 Sep 2007 11:26:52 +0200
Message-ID: <18150.24412.855004.90148@notabene.brown>
References: <20070911083200.GA3409@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Mark Hindley <mark@hindley.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: message from Mark Hindley on Tuesday September 11
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday September 11, mark@hindley.org.uk wrote:
> This oops appeared over night on a box running 2.6.23-rc5 (recent with the
> tcp_input.c fix).
> 
> I can't find a similar one reported.


Okay..... this is weird.
> 
> Mark
> 
> 
> BUG: unable to handle kernel NULL pointer dereference at virtual address 0000007e 
                                                                           ^^^^^^^^

That is the bad address,

> EFLAGS: 00010246   (2.6.23-rc5-2-mcyrixiii #1)
> EIP is at ip_fragment+0x7f/0x680
> eax: c3c09c00   ebx: 00000000   ecx: b524d006   edx: 0000007b
                                                  ^^^^^^^^^^^^^

It looks like an offset of 3 from edx.  I got that from decoding:

> Code: .... <00> ba 03 00 00 00 bf a6 ff ff

which is 
   0:   00 ba 03 00 00 00         add    %bh,0x3(%rdx)

However that instruction doesn't appear in ip_fragment.
The code in ip_fragment reads:
  27:   b9 04 00 00 00            mov    $0x4,%ecx
                    ^^
  2c:   ba 03 00 00 00            mov    $0x3,%edx
        ^^^^^^^^^^^^^^

which contains the bytes of the offending instruction.
Note that $0x4 is ICMP_FRAG_NEEDED and $0x3 is ICMP_DEST_UNREACH:
these are args to icmp_send.  So the latter is the correct disassembly
based on the C code.

So somehow the kernel is jumping to a bad address.  I don't know how
that would happening.... maybe a single bit error in memory or a
register???

NeilBrown
