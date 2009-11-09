From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] proc: revalidate dentry returned by proc_pid_follow_link
Date: Sun, 08 Nov 2009 19:30:55 -0800
Message-ID: <m1hbt49xxs.fsf@fess.ebiederm.org>
References: <1257513594-31071-1-git-send-email-jlayton@redhat.com>
	<20091106203601.GD27751@shareable.org>
	<20091106160612.4cd05e76@tlielax.poochiereds.net>
	<m17hu1miea.fsf@fess.ebiederm.org>
	<20091108201237.79af5cac@tupile.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53281 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538AbZKIDaz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Nov 2009 22:30:55 -0500
In-Reply-To: <20091108201237.79af5cac-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org> (Jeff Layton's message of "Sun\, 8 Nov 2009 20\:12\:37 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

>> Hmm.  Looking at the code I get the impression that a file bind mount
>> will have exactly the same problem.
>> 
>> Can you confirm.
>> 
>> If file bind mounts also have this problem a bugfix to to just
>> proc seems questionable.
>> 
>
> I'm not sure I understand what you mean by "file bind mount". Is that
> something like mounting with "-o loop" ?

# cd /tmp
# echo foo > foo
# echo bar > bar
# mount --bind foo bar
# cat bar
foo
#

> I'm not at all opposed to fixing this in a more broad fashion, but as
> best I can tell, the only place that LAST_BIND is used is in procfs.

proc does appear to be the only user of LAST_BIND.  With a file bind
mount we can get to the same ok: label without a revalidate.  The
difference is that we came from __follow_mount instead of follow_link.

At least that is how I read the code.

Eric
