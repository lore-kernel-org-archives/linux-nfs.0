From: "NeilBrown" <neilb@suse.de>
Subject: Re: [PATCH] nfsd: be creative with time stmaps so that NFS client
     can reliably discover changes
Date: Thu, 19 Mar 2009 12:33:45 +1100 (EST)
Message-ID: <b58af8ee1a07d5b0f214d5dac82f5e99.squirrel@neil.brown.name>
References: <18848.63422.177485.115103@notabene.brown>
    <18864.48837.701952.150752@notabene.brown>
    <20090318232519.GM18894@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:50547 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270AbZCSBdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2009 21:33:54 -0400
In-Reply-To: <20090318232519.GM18894@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, March 19, 2009 10:25 am, J. Bruce Fields wrote:
> On Fri, Mar 06, 2009 at 05:12:21PM +1100, Neil Brown wrote:
>> On Sunday February 22, neilb@suse.de wrote:
>
> Sorry for the slow turnaround!  I'm conflicted:

Late is much better than never - thanks for keeping this alive.

>
>> >
>> > Hi Bruce,
>> >  here is my current version if the [cm]time fiddling patch for your
>> >  consideration.
>> >  If you like it, you can pull it from
>> >       git://neil.brown.name/linux-2.6 nfsd-devel
>> >  (or just extract it from the email)
>> >
>>
>> It turned out that there was a problem with that patch.
>> Making the mtime of a file appear 1 nanosecond in the past for the first
>> second of its existence confuses (at least) tar.
>> When tar extracts a symlink that begins with '/', it first creates a
>> place-holder file and then when the whole archive has been extracted
>> it goes around checking all the place holder files to make sure they
>> haven't changed.  If they haven't they are replaced with the symlink.
>> This is some kind of protection against malicious tar archives which
>> could create a symlink, then install a file through it to some place
>> that the users isn't expecting.
>>
>> Anyway, the previous nfsd patch causes tar to think that (almost) all
>> those place holder files had been changed and so the symlinks aren't
>> extracted.
>
> Out of curiosity, what are the operations that it performs on creating
> the file?  (In theory a single create should do the job, so it's not
> obvious there'd be a second operation to trigger your mtime decrement.)

tar wants to protect against the possibility of an archive containing:

   foo  symlink to /etc
   foo/password   file containing bad stuff

and admin might extract that thinking that it would only affect the
current directory but it doesn't.
So when tar see the "/etc" symlink, it doesn't create it but instead
creates an empty file "foo".  It then does an lstat of the file and
remembers the mtime.
When it has finished extracting everything it goes back through its
list of symlink and checks the placeholder file.  It if it unchanged
(same mtime, size zero) it removes the file and installs the symlink.
If it has changed it assumes that something evil was going on and
leaves the file there.

So the seqeunce is
   create
   stat
   <time passes>
   stat
and tar requires the two stats to return the same size/mtime.
With my original patch they didn't.

>
>> I guess it isn't unreasonable for an application to expect that the
>> mtime of a file isn't going to change unexpectedly.  So there goes
>> some of my clever idea.
>>
>> I think it is still safe to fiddle ctime on directories.  I believe
>> ctime is much less frequently checked, and directories are much more
>> likely to be changed independently by multiple programs.
>>
>> Further, directories are the particular need.  If files change
>> multiple times in a second it is very likely that their size will
>> change as well and that will invalidate cached values.  Also locking
>> can be used to force the client to flush the cache where as that is
>> not possible with directories.
>
> This sounds reasonably careful, and I agree with the above.
>
> On the other hand, I still have this general feeling that it might be a
> bit too clever, and a preference for behavior that's been broken for
> ages in a known way over new behavior that's probably better in almost
> all cases, but that still might turn out to break something we haven't
> thought of yet.
>
> Ugh.  Is there some way I can get out of a decision here?  Will this get
> some more testing from your users if we put off merging this for a
> little longer?

Customers are using this patch now and haven't reported any more problems.
I'm sure they will if they find any.  But I also suspect that there will
be many applications that the do no use, and it is not inconceivable that
one of them would have an awkward expectation like tar did.

At the very least that part of the change that affects NFSv4 changeids
should go in.  I think this is completely safe from side effects.
It violates the NFSv4 spec for what a changeid should be just as the
current code does, but it violates it in a way that is safer - possibly
showing a change where no change exists rather than possibly showing no
change when a real change exists.


>
> Signed with cowardice....--b.

Thanks,
NeilBrown

