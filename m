From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Ping: d_obtain_alias
Date: Sat, 21 Feb 2009 10:41:19 +0200
Message-ID: <499FBE2F.6030605@panasas.com>
References: <499FA991.8080909@panasas.com> <20090221174046.GA27374@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:7300 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751357AbZBUSlx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Feb 2009 13:41:53 -0500
In-Reply-To: <20090221174046.GA27374@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb. 21, 2009, 19:40 +0200, Christoph Hellwig <hch@infradead.org> wrote:
> All the nfs exported filesystem are tied intimately to the kernel,
> so yes, this is an internal export.

I think that it would help if linux had a clear technical definition of
what being "intimately tied to" actually means and what makes usage
of an API derived work or not.

By making d_obtain_alias EXPORT_SYMBOL_GPL you made the exported API in
fs/dcache.c inconsistent.  What makes d_obtain_alias so different from
other functions in this file that are exported using EXPORT_SYMBOL?

looking at Documentation/DocBook/kernel-hacking.tmpl the guideline
it gives for using EXPORT_SYMBOL_GPL is "It implies that the function
is considered an internal implementation issue, and not really an
interface."

Rather than ranting about licensing I'd rather spend time on thinking
about what makes a function a part of a module's formal API
that's intended to be used by modules that are "consumers" or "users"
of the API (regardless of their license!) and what functions are exported
as a kernel-internal interface to other modules that co-operate with the
module (call them co-modules if you'd like) and that would be just
public (and not exported) if both modules were statically linked together.

I think that confusing licensing with the export symbol definition is
obstructing the technical part of the API design...

> 
> Non-GPL filesystem are illegal to distribute anyway, so I don't know why
> you even bother.

Hmm, I won't get down to this level of argument.

Benny

> 
> On Sat, Feb 21, 2009 at 09:13:21AM +0200, Benny Halevy wrote:
>> Christoph?
>>
>> On Feb. 16, 2009, 19:31 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
>>
>> Christoph,
>>
>> I see that in 4ea3ada2955e4519befa98ff55dd62d6dfbd1705,
>> you declared d_obtain_alias() as EXPORT_SYMBOL_GPL
>> and that it's supposed to replace d_alloc_anon which
>> was declared as EXPORT_SYMBOL and thus available to any
>> loadable module.
>>
>> Do you consider d_obtain_alias() an internal API?
>> What exported API non-GPL'ed loadable file systems are
>> supposed to use now for fh_to_dentry?
>>
>> Benny
> ---end quoted text---
