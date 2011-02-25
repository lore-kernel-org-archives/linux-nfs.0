Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:47812 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932265Ab1BYQnZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Feb 2011 11:43:25 -0500
From: Ferenc Wagner <wferi@niif.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Seemingly inconsistent directory state under NFSv4
References: <87sjvuiwnl.fsf@tac.ki.iif.hu> <87d3mkhvgb.fsf@tac.ki.iif.hu>
	<20110223193929.GA13399@fieldses.org> <87vd098jk5.fsf@tac.ki.iif.hu>
	<20110224172747.GA22070@fieldses.org>
Date: Fri, 25 Feb 2011 17:43:23 +0100
In-Reply-To: <20110224172747.GA22070@fieldses.org> (J. Bruce Fields's message
	of "Thu, 24 Feb 2011 12:27:47 -0500")
Message-ID: <87tyfsqd3o.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Thu, Feb 24, 2011 at 05:48:58PM +0100, Ferenc Wagner wrote:
>
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> One client removed the file, and another could still access it by name
>> (although not present in the directory listing).  So it could have been
>> a client-client conflict, even though we couldn't prove that the removed
>> file was actually in use on the client.  Is there a way to list the
>> delegations being hold by a client?
>
> Not really.  They'll show up as LEASE entries in /proc/locks, with the
> pid of an nfsd process, but no way to associate them with a client.

Well, thanks, this is something.  I'll check when it happens again.
There are lots of such lines, so chances are that will be it.

> Some way to dump lock (and other state) information might be a nice
> thing to have some day for debugging and tuning.

Yes, very much!  I guess the info is more or less readily available in
the kernel, just isn't exported to userspace.  Looks like a job for
debugfs.

>>> You can turn off delegations completely with
>>> 	echo 0 >/proc/sys/fs/leases-enable
>>> before starting the nfs server.
>> 
>> Wouldn't I lose most of the efficiency advantages of NFSv4 with that
>> move?
>
> Probably so.  It would at least be a way to verify whether delegations
> are the source of your problem, if you have a reproduceable test case.

Not yet, unfortunately.  But we're trying to work one out.  It's pretty
rare, so only mildly disturbing, but when it hits, it hits hard...
-- 
Thanks,
Feri.
