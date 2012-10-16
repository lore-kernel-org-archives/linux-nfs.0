Return-Path: linux-nfs-owner@vger.kernel.org
Received: from science.horizon.com ([71.41.210.146]:28980 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752146Ab2JPBs0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 21:48:26 -0400
Date: 15 Oct 2012 21:48:24 -0400
Message-ID: <20121016014824.4952.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux@horizon.com, lm@bitmover.com, Trond.Myklebust@netapp.com
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90923ED96@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond.Myklebust@netapp.com wrote:
> SSBkbyBtaW5kOyBpdCBpcyBjbGVhcmx5IHN0YXJ0aW5nIHRvIGJpdHJvdCBkdWUg
> dG8gYW4gYWJzZW5jZSBvZiB1c2Vycy4NCk1haW50ZW5hbmNlIG9mIHVudXNlZCBjb2RlIGlzIGFj
> dHVhbGx5IF9tb3JlXyBvZiBhIHBhaW4sIG5vdCBsZXNzLg0KDQpTbyB1bmZzZCBpcyBvbmUgc29s
> dXRpb24uIEtlZXBpbmcgYSBWTSB3aXRoIGFuIG9sZGVyIHZlcnNpb24gb2YgdGhlDQpMaW51eCBr
> ZXJuZWwgdGhhdCBzdGlsbCBzdXBwb3J0cyBORlN2MiBpcyBhbm90aGVyLiBWb2x1bnRlZXJpbmcg
> dG8NCm1haW50YWluIHRoZSBjb2RlIGlzIGEgdGhpcmQuDQoN

Which can be base64 decoded (why was it ever ENcoded?) to

> I do mind; it is clearly starting to bitrot due to an absence of users.
> Maintenance of unused code is actually _more_ of a pain, not less.
>
> So unfsd is one solution. Keeping a VM with an older version of the
> Linux kernel that still supports NFSv2 is another. Volunteering to
> maintain the code is a third.

If I might ask, though, is the pain concentrated more on the client or
the server side?

NFSv2 server support seems a fairly simple matter of some old
compatibility RPC calls.  The main pain is the limited size of the file
handle and (especially) readdir cookies.

Client support is probably more complicated, as NFS's "stateless server"
model puts the bulk of the complexity on the client, and you need a
thicker layer of logic to translate the operations into a different
vocabulary pf RPC calls.

I don't think NFSv2 client support would be mourned much; trying to to
use such an ancient limited machine as a file server seems stupid.

It's NFSv2 server support that I, and I believe Larry, are interested
in preserving, in order to provide services to ancient clients.

The only real use of v2 client code is te test the server.
