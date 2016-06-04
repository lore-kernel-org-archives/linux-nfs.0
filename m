Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:36180 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcFDMZW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jun 2016 08:25:22 -0400
Received: by mail-qk0-f170.google.com with SMTP id i187so59993377qkd.3
        for <linux-nfs@vger.kernel.org>; Sat, 04 Jun 2016 05:25:22 -0700 (PDT)
Message-ID: <1465043118.11546.10.camel@poochiereds.net>
Subject: Re: Dcache oops
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>, linux-nfs@vger.kernel.org
Date: Sat, 04 Jun 2016 08:25:18 -0400
In-Reply-To: <20160604005611.GA14480@ZenIV.linux.org.uk>
References: <74306F63-DBDF-4DED-85D2-5C3FB21B8A1E@linuxhacker.ru>
	 <20160603182203.GR14480@ZenIV.linux.org.uk>
	 <4285E00F-7228-485C-AD32-97552ED746F2@linuxhacker.ru>
	 <20160603200759.GS14480@ZenIV.linux.org.uk>
	 <CA+55aFznPit97evuwZHdCG55=N0QbkFSST2ydKxvExQTR-YXTg@mail.gmail.com>
	 <20160603212652.GT14480@ZenIV.linux.org.uk>
	 <CA+55aFyYkbXqoJ3PqfrnxWDEXJM_BH6Q_OdKf+UVJYEUF4gdQA@mail.gmail.com>
	 <20160603222355.GW14480@ZenIV.linux.org.uk>
	 <20160603223700.GY14480@ZenIV.linux.org.uk>
	 <DA67EEEA-D769-4D0F-9C20-6145F2B0808F@linuxhacker.ru>
	 <20160604005611.GA14480@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-06-04 at 01:56 +0100, Al Viro wrote:
> On Fri, Jun 03, 2016 at 07:58:37PM -0400, Oleg Drokin wrote:
> 
> > 
> > > 
> > > EOPENSTALE, that is...  Oleg, could you check if the following works?
> > Yes, this one lasted for an hour with no crashing, so it must be good.
> > Thanks.
> > (note, I am not equipped to verify correctness of NFS operations, though).
> I suspect that Jeff Layton might have relevant regression tests.  Incidentally,
> we really need a consolidated regression testsuite, including the tests you'd
> been running.  Right now there's some stuff in xfstests, LTP and cthon; if
> anything, this mess shows just why we need all of that and then some in
> a single place.  Lustre stuff has caught a 3 years old NFS bug (missing
> d_drop() in nfs_atomic_open()) and a year-old bug in handling of EOPENSTALE
> retries on the last component of a trailing non-embedded symlink.  Neither
> is hard to trigger; it's just that relevant tests hadn't been run on NFS,
> period.
> 
> Jeff, could you verify that the following does not cause regressions in
> stale fhandles treatment?  I want to rip the damn retry logics out of
> do_last() and if the staleness had only been discovered inside of
> nfs4_file_open() just have the upper-level logics handle it by doing
> a normal LOOKUP_REVAL pass from scratch.  To hell with trying to be clever;
> a few roundtrips it saves us in some cases is not worth the complexity and
> potential for bugs.  I'm fairly sure that the time spent debugging this
> particular turd exceeds the total amount of time it has ever saved,
> and do_last() is in dire need of simplification.  All talk about "enough eyes"
> isn't worth much when the readers of code in question feel like ripping their
> eyes out...
> 

Agreed. I see no need to optimize an error case here. Any performance
hit that we'd get here is almost certainly acceptable in this
situation. The main thing is that we prevent the ESTALE from bubbling
up into userland if we can avoid it by retrying.

No, I didn't have the test for this anymore unfortunately. RHQA might
have one though.

Either way, I cooked one up that does this on the server:

#!/bin/bash

while true; do
	rm -rf foo
	mkdir foo
	echo foo > foo/bar
	usleep 100000
done

...and then this on the client after mounting the fs with
lookupcache=none and noac.

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv)
{
	int fd;

	while(1) {
		fd = open(argv[1], O_RDONLY);
		if (fd < 0) {
			if (errno == ESTALE) {
				printf("ESTALE");
				return 1;
			}
			continue;
		}
		close(fd);
	}
	return 0;
}

I did see some of the OPEN compounds come back with NFS4ERR_STALE on
the PUTFH op but no corresponding ESTALE error in userland. So, this
patch does seem to do the right thing.

Reviewed-and-Tested-by: Jeff Layton <jlayton@poochiereds.net>
