Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:59566 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753615Ab3ERMKM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 May 2013 08:10:12 -0400
In-Reply-To: <20130517165038.GA7147@umich.edu>
References: <OFD54C462E.9A1446D0-ONC1257B6E.004D4190-C1257B6E.00507192@transmode.se> <20130517165038.GA7147@umich.edu>
To: Jim Rees <rees@umich.edu>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: Is the code stateid_generation_after()in legal C?
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OF34F194FB.237EF963-ONC1257B6F.0041DA05-C1257B6F.0042D90F@transmode.se>
Date: Sat, 18 May 2013 14:10:08 +0200
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees <rees@umich.edu> wrote on 2013/05/17 18:50:38:
> 
> Joakim Tjernlund wrote:
> 
>   static bool stateid_generation_after(stateid_t *a, stateid_t *b)
>   {
>           return (s32)a->si_generation - (s32)b->si_generation > 0;
>   }
> 
>   overflow is undefined for signed integers and gcc uses that nowadays.
>   Not sure if that can affect the above code?
> 
> I guess the intent there is to account for stateid wraparound. But it's 
not
> clear to me this is doing the right thing. I think C specifies overflow
> behavior for unsigned but not signed. 

Right, the below test prog demonstrates the signed overflow problem in 
newer gcc's
#include <assert.h>

int foo(int a) {
  assert(a+100 > a);
  printf("%d %d\n",a+100,a);
  return a;
}

int main() {
  foo(100);
  foo(0x7fffffff);
}

> So shouldn't it be something more like this?
> 
>     (s32)(a->si_generation - b->si_generation) > 0
> 
> Either way, this probably deserves a comment.
