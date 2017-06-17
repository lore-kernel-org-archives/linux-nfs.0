Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:39623 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbdFQPLy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jun 2017 11:11:54 -0400
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a filesystem
 context [ver #5]
To: Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Theodore Ts'o <tytso@mit.edu>
Cc: Casey Schaufler <casey@schaufler-ca.com>, mszeredi@redhat.com,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
References: <20170617095755.z623wmwgwcw76wce@thunk.org>
 <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com>
 <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk>
 <1402.1497472929@warthog.procyon.org.uk>
 <77078d8b-e8dc-5cd2-2f09-1e796d8e0e2c@schaufler-ca.com>
 <9029.1497709089@warthog.procyon.org.uk>
 <1497711392.4684.11.camel@redhat.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d1bdc7bc-94f5-439f-915a-9dea06f646f2@infradead.org>
Date: Sat, 17 Jun 2017 08:11:50 -0700
MIME-Version: 1.0
In-Reply-To: <1497711392.4684.11.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/17/2017 07:56 AM, Jeff Layton wrote:
> On Sat, 2017-06-17 at 15:18 +0100, David Howells wrote:
>> Theodore Ts'o <tytso@mit.edu> wrote:
>>
>>> I don't know that this is a hard and fast rule.  Struct bio uses a
>>> "bi_" prefix (e.g., bi_error, bi_opf, bi_iter, etc.).
>>
>> Linus told me to stop doing it.
>>
>> David
> 
> 
> That's a pity... I tend to like little prefixes on fields too. Trying to
> find all occurrences of a symbol called "flags" in cscope is a losing
> exercise.
> 
> Do you have a reference to the discussion so I can understand the
> rationale there?

Ack. This doesn't seem helpful.

He also objected to drivers with file names that begin with the parent
directory name, but we still have hundreds of those (see clk/, extcon/,
gpio/, hid/, i2c/, leds/ [then I stopped looking]).


-- 
~Randy
