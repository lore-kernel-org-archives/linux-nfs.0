Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:17016 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752161AbbJMT6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 15:58:51 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] Adding issync field to delegreturn_exit tracepoint
References: <CAN-5tyHxP276Re_Zm4mV9F+EY1Czq5SfbPJ1Os_CQd0hfhFzdA@mail.gmail.com>
	<CAHQdGtSg5E0jrEhK-aLht6WdmMTFFBUuG8tUX7sHJDUj+67-4Q@mail.gmail.com>
	<CAN-5tyHMCMekT0gJE1zNQLO0P5bVgjr_PuQF1BYhNy7n4KBvHg@mail.gmail.com>
	<CAHQdGtQfBZ4yRCkZ0-voFekTEx8fJ1kHCzrmtjr3RHh-dqOuww@mail.gmail.com>
	<CAN-5tyGme1rm+hD0JpOc3co0=_u2hzPwR7eN3AT4_TjVA4NkDA@mail.gmail.com>
	<CAN-5tyFZRU3zCSKU7wNoGzwDF9hn2Vvq6+JL9cWQnuhwoBftyg@mail.gmail.com>
	<CAHQdGtRzyiqjEj8Z2eBjk6ugzG8maK+F2BnO69JsX4ntCOzCcw@mail.gmail.com>
	<CAN-5tyHGp4ihz3pzcmX+xjm5aba8SA3Pfxw-nxNTKv9tFikaGw@mail.gmail.com>
	<CAHQdGtQJm6rFiNgF+SVCx_3SAnzBgHu8mXToWu_uNwJHYCZzqA@mail.gmail.com>
	<m2fv1esla2.fsf@discipline.rit.edu>
	<CAHQdGtS9NKgi0EcS-vQy9sVveGG-id4cKeTBr7dAeTs+93+Cuw@mail.gmail.com>
Date: Tue, 13 Oct 2015 15:58:50 -0400
In-Reply-To: <CAHQdGtS9NKgi0EcS-vQy9sVveGG-id4cKeTBr7dAeTs+93+Cuw@mail.gmail.com>
	(Trond Myklebust's message of "Tue, 13 Oct 2015 15:46:56 -0400")
Message-ID: <m27fmqr151.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> The server should honour the open without repeating the delegation.
>
> The client already knows about the delegation due to the first open,
> so there is no value whatsoever in repeating it. In addition, as you
> see from Olga's example, it causes races with the return of that
> delegation.

Thanks for the clarification, I'll be updating my v2 patch to suppress both
types of delegations ("duplicate" and "repeated").

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
