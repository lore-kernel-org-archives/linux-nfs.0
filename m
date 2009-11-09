From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] proc: revalidate dentry returned by
 proc_pid_follow_link
Date: Mon, 9 Nov 2009 08:11:31 -0500
Message-ID: <20091109081131.7ebfde76@tlielax.poochiereds.net>
References: <1257513594-31071-1-git-send-email-jlayton@redhat.com>
	<20091106203601.GD27751@shareable.org>
	<20091106160612.4cd05e76@tlielax.poochiereds.net>
	<m17hu1miea.fsf@fess.ebiederm.org>
	<20091108201237.79af5cac@tupile.poochiereds.net>
	<m1hbt49xxs.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664AbZKINLc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2009 08:11:32 -0500
In-Reply-To: <m1hbt49xxs.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 08 Nov 2009 19:30:55 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Jeff Layton <jlayton@redhat.com> writes:
> 
> >> Hmm.  Looking at the code I get the impression that a file bind mount
> >> will have exactly the same problem.
> >> 
> >> Can you confirm.
> >> 
> >> If file bind mounts also have this problem a bugfix to to just
> >> proc seems questionable.
> >> 
> >
> > I'm not sure I understand what you mean by "file bind mount". Is that
> > something like mounting with "-o loop" ?
> 
> # cd /tmp
> # echo foo > foo
> # echo bar > bar
> # mount --bind foo bar
> # cat bar
> foo
> #
> 
> > I'm not at all opposed to fixing this in a more broad fashion, but as
> > best I can tell, the only place that LAST_BIND is used is in procfs.
> 
> proc does appear to be the only user of LAST_BIND.  With a file bind
> mount we can get to the same ok: label without a revalidate.  The
> difference is that we came from __follow_mount instead of follow_link.
> 
> At least that is how I read the code.
> 

Thanks.

Yes, you're correct. That scenario does seem to have a similar problem.
I'm not quite sure yet how to fix it there yet.

It's easy enough to force a d_revalidate at a higher level. The tricky
bit is what to do when that returns 0 or an error. When I spoke to Al
about this, he suggested returning -ESTALE from the follow_link routine
if that occurs. That would force LOOKUP_REVAL to get set and cause the
whole chain of dentries to be revalidated back up to the root (if
necessary).

That's a little more difficult in the file bind mount case as I don't
see where it calls link_path_walk at all and hence can't really deal
with an ESTALE on a reval properly. I'll need to study this code some
more to see what the right fix is. If you (or anyone) has a suggestion,
I'd love to hear it.

-- 
Jeff Layton <jlayton@redhat.com>
