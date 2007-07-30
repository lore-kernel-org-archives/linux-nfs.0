From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 01/23] mount.nfs: Support double-wide characters
 in printed strings
Date: Mon, 30 Jul 2007 15:30:37 +1000
Message-ID: <18093.30589.679002.53663@notabene.brown>
References: <20070728214913.21871.41624.stgit@localhost.localdomain>
	<18092.17434.520955.494157@notabene.brown>
	<46ACF2F2.80602@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFNqB-0001aF-UT
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 22:30:48 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFNqF-00009s-7N
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 22:30:52 -0700
In-Reply-To: message from Chuck Lever on Sunday July 29
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sunday July 29, chuck.lever@oracle.com wrote:
> > So please either show me the error of my thinking, or stick to adding
> > _() to translatable strings.
> > 
> > Much of this patch is good and wanted, I'm not sure about the whole.
> > Similarly for patch 2.
> 
> Yeah, the options stuff was a mistake which I thought I had avoided. 
> Will fix all this up and post a fresh patch set.
> 
> But my impression was a double-byte "." is not the same as a single-byte 
> ".".  I'm not an expert, and would be happy if someone (like a 
> distributor) had an internationalization expert they could loan us.

I think you are confusing two things (that are easily confused).
With some loss of generality, I will call them unicode and utf, the
Unicode Transport Format(??)

Unicode uses wide characters, 16bits each. 'wchar'.  The unicode '.'
is different from the ASCII '.' simply because they have different
numbers of bits (though I think the low order bits are the same, and
the high order bits in unicode are all zero).

Code which wants to process international character sets a character
at a time needs handle the text as wchars, typically arrays of wchars.
They are two bytes each.

However code that just wants to work with known strings and doesn't
really care about the content can use UTF instead.  UTF encodes a
Unicode string using 1, 2 or 3 bytes for each character.  All 7-bit
ASCII symbols have their standard 1byte encoding.  Other symbols are 2
or 3 bytes.

So if you just want to print a message, you can use an array of
'char' and store any international text in there.  No need to
explicitly use wchar.

If you want to use a string value that can be localised, you use
   _("string")
and the NLS tools will allow that to be swapped for a localised
version, possibly using UTF to represent unicode characters, at
runtime.

So you only need _(xxx) for translatable strings.  Things like " " (a
space), "\n" definitely don't need translation.  Things like ":" could
conceivably benefit from translation, but I doubt that it really makes
sense to translate them in isolation.  Places where punctuation has a
strong meaning like in dates, times, currency etc have separate
functionality for doing localisation (strftime, strfmon) so for normal
usage, I don't think it is appropriate to translate individual
punctuation characters.

Does that make sense?

> 
> > I only got 12 of the 23 patches??
> 
> The list didn't see half of these either.  Will investigate.  I probably 
> shut down my laptop before it was done relaying the patches.

Grin...
I seem to have them now.  Thanks.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
