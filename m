Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbbFBSlY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2015 14:41:24 -0400
Date: Tue, 2 Jun 2015 14:41:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4lib: add test name as a compound tag
Message-ID: <20150602184120.GA1215@fieldses.org>
References: <1433227098-4181-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433227098-4181-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 02, 2015 at 08:38:18AM +0200, Tigran Mkrtchyan wrote:
> allowes to easy trace tests, e.q: [st_verify.py:_try_mand]

Thanks, applied.

> a similar fix as 2b41c3e, but for 4.0. Introdces a bit
> of code duplication, but this is forced by test suite structure.

I looked into that for a while earlier this year.  I started out looking
for duplicated code (e.g. there's two complete copies of the "ply"
library) and making it shared.  I removed a lot of lines of code that
way but didn't really feel like I'd really simplified anything.

So I eventually decided it would be better to add support for 4.0 to the
code under nfs4.1/ and then remove nfs4.0/ once all the tests have been
ported over.

But I only got as far as basic state setup (SETCLIENTID,
SETCLIENTID_CONFIRM, OPEN, OPEN_CONFIRM), without any backchannel
support and without the 4.0 tests ported over yet.  Not sure if/when I
might get back to that.

--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.0/nfs4lib.py    | 18 +++++++++++++++++-
>  nfs4.1/nfs4client.py |  3 ++-
>  2 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
> index f196bef..5031feb 100644
> --- a/nfs4.0/nfs4lib.py
> +++ b/nfs4.0/nfs4lib.py
> @@ -40,6 +40,8 @@ import struct
>  import socket
>  import sys
>  import re
> +import inspect
> +from os.path import basename
>  
>  class NFSException(rpc.RPCError):
>      pass
> @@ -313,8 +315,13 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
>          """Make COMPOUND procedure call"""
>          if type(argarray) is not list:
>              raise "Need list for argarray"
> +
> +        if len(tag) == 0:
> +            compound_tag = self.create_tag()
> +        else:
> +            compound_tag = tag
>          # Make the actual call
> -        compoundargs = COMPOUND4args(argarray=argarray, tag=tag,
> +        compoundargs = COMPOUND4args(argarray=argarray, tag=compound_tag,
>                                       minorversion=minorversion)
>          if SHOW_TRAFFIC:
>              print
> @@ -367,6 +374,15 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
>  
>          return res
>  
> +    def create_tag(self):
> +        current_module = inspect.getmodule(inspect.currentframe().f_back)
> +        current_stack = inspect.stack()
> +        stackid = 0
> +        while current_module == inspect.getmodule(current_stack[stackid][0]):
> +              stackid = stackid + 1
> +        test_name = '%s:%s' % (basename(current_stack[stackid][1]), current_stack[stackid][3])
> +        return test_name
> +
>      def init_connection(self, id=None, verifier=None, cb_ident=None):
>          """Do setclientid/setclientidconfirm combination"""
>          # SETCLIENTID
> diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
> index 62ccc3a..14b34d2 100644
> --- a/nfs4.1/nfs4client.py
> +++ b/nfs4.1/nfs4client.py
> @@ -307,9 +307,10 @@ class NFS4Client(rpc.Client, rpc.Server):
>          return s
>  
>      def create_tag(self):
> +        current_module = inspect.getmodule(inspect.currentframe().f_back)
>          current_stack = inspect.stack()
>          stackid = 0
> -        while basename(current_stack[stackid][1]) == 'environment.py' or basename(current_stack[stackid][1]) == 'nfs4client.py':
> +        while current_module == inspect.getmodule(current_stack[stackid][0]):
>                stackid = stackid + 1
>          test_name = '%s:%s' % (basename(current_stack[stackid][1]), current_stack[stackid][3])
>          return test_name
> -- 
> 2.4.2
