From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Mon, 5 Jun 2006 11:20:18 +0200
Message-ID: <20060605092018.GB4714@uio.no>
References: <20060601155929.GA890@uio.no>
	<17539.41286.81087.480257@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FnBGB-0004cW-1a
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 02:20:31 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FnBGB-0005uq-1f
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 02:20:31 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FnBG8-0000wX-BD
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 02:20:31 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1FnBFy-000770-F9
	for nfs@lists.sourceforge.net; Mon, 05 Jun 2006 11:20:19 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1FnBFy-0001FU-00
	for <nfs@lists.sourceforge.net>; Mon, 05 Jun 2006 11:20:18 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <17539.41286.81087.480257@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, Jun 05, 2006 at 01:13:10PM +1000, Neil Brown wrote:
> I've noticing this problem before and always shied away from it.
> While the value might be "unpredictable", someone might be depending
> on the current behaviour, and changing it could break things for some
> people while fixing things for others...
> Can you -- or anyone else -- convince me that this is really a good
> and safe thing to do?  I'm fairly open to being convince, but I don't
> feel I'm familiar enough with all the issues and would love to hear
> from someone who is.
> My particular concern is "What might it break, and how much of a
> problem could that be?" 

The biggest problem is, IMO: People expect stuff to be done as "nobody" (or,
at least uid 65534, which is mapped to "nobody" on all systems that I know).
"nobody" in Linux (as opposed to, say, Hurd) is not really someone with no
rights, but can own files etc. -- so if you had something owned by "nobody",
or "nobody" was a member of some specific group, you'd expect that to work.
Now it can easily vary between different systems, which is rather bad.

As far as I'm concerned, we've already probably had multiple instances of
this changing (from 65534 to 4294967294, when upgrading) and nobody really
noticed; I don't see the harm of changing it back to it's the same
everywhere.

> Hmm... I think the real bug here is that a '#' is treated as starting
> a comment even if it isn't at the start of a word.
> xgetc shouldn't check for '#', xgettok should.
> The kernel doesn't currently escape '#' in /proc/fs/nfs/exports so
> reading pathnames containing '#' from there will still be a problem.
> 
> So I might fix that too..... could that break anything?

Well, I think it's at least inconsistent with the man page as it's written
today; in that case, the man page should be rewritten too. Look at the
original bug report on http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=239230
to see the entire section.

>>  - mountd_state_directory.diff: Let the user select (via a new parameter)
>>    the path to the NFS state directory for mountd, to match the statd
>>    functionality. (If you take it in, you might want to remove the part in
>>    the manpage saying it's Debian-specific.)
> Seems pretty pointless ;-)  but that won't stop be accepting it...

It is reportedly useful for read-only /var -- people with special clustering
needs complained about the lack of such things, IIRC.

> I love getting patches that also update the man page!  Now if I can
> only train people to update ChangeLog too :-)

:-)

> Hmmm. I'm not sure I like removing blank lines just for the same of
> some silly warning - blank lines are good for readability.
> I have instead replaced them with a single ' which removes the warning
> and is almost as good as a blank.

OK, that sounds good too. I don't know why the blanks are disallowed, but
just leaving a man page with known errors wouldn't be too good either. :-)

/* Steinar */
-- 
Homepage: http://www.sesse.net/


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
