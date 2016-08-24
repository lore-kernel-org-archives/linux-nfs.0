Return-Path: <bfields@fieldses.org>
Date: Wed, 24 Aug 2016 11:16:20 -0400
From: Fields Bruce James <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Coddington Benjamin <bcodding@redhat.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: I can't get no readdir satisfaction
Message-ID: <20160824151620.GJ3938@fieldses.org>
References: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
 <F9D0E173-9E64-4BC4-87FB-0F6F4EEBF4C7@primarydata.com>
 <98E39192-4203-4EB8-BDE0-2A4ABFCAA92B@redhat.com>
 <81D2E080-0697-4B26-BE38-5E8AC35C2EA4@primarydata.com>
 <20160824135603.GF3938@fieldses.org>
 <9AB01AA0-9E40-4DD9-8C97-0EB4519E7816@primarydata.com>
 <20160824142049.GG3938@fieldses.org>
 <0876C5BD-5BF1-400B-9BDE-0D7C3CC943FD@primarydata.com>
 <20160824144024.GH3938@fieldses.org>
 <A52A7ED8-D2B6-424D-87FE-9F77C14BEC93@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <A52A7ED8-D2B6-424D-87FE-9F77C14BEC93@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 24, 2016 at 02:53:10PM +0000, Trond Myklebust wrote:
> 
> > On Aug 24, 2016, at 10:40, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Wed, Aug 24, 2016 at 02:26:21PM +0000, Trond Myklebust wrote:
> >> 
> >>> On Aug 24, 2016, at 10:20, <bfields@fieldses.org> wrote:
> >>> I may be misunderstanding what the client's doing.  If it's doing
> >>> something like this:
> >>> 
> >>> 	- return first hundred entries to user
> >>> 	- throw out cache, restart readdir with cookie 0.
> >>> 	- skip first hundred entries, return entries 101-200 to user.
> >> 
> >> No. If the client has a cached cookie acting as the cursor, then we look for that cookie in the new stream. If we don’t find that cookie, then we do another readdir where that cookie acts as an argument, and use that to figure out where the stream now continues.
> > 
> > Got it, thanks, so the struct file caches the real server side cookie
> > even after you throw out the cached entries?  OK, I guess I need to make
> > another attempt at understanding the actual code, apologies.
> > 
> > (Doesn't that mean that in the case your last position was a deleted
> > file, you're probably going to have to read the entire directory to find
> > out the cookie's not there?  It seems so much more painful than starting
> > off with the last cookie.)
> 
> How do you cache the results of such a readdir? You'll have no reference point to figure out where you are in the stream.
> Also, how do you convert that cookie into an offset that telldir() can use?

No idea.  But then, I don't really understand how we're going to do that
even after reading the whole directory.  Any telldir offsets that we've
returned previously are in the future going to index into a completely
new array, so they seem kind of meaningless.

--b.
