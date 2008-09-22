From: "Hans-Peter Jansen" <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 22 Sep 2008 20:45:44 +0200
Message-ID: <200809222045.45990.hpj@urpla.net>
References: <20080905191939.GG22796@merfinllc.com> <200809221805.48463.hpj@urpla.net> <1222101322.7615.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54445 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbYIVSpw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 14:45:52 -0400
In-Reply-To: <1222101322.7615.6.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Montag, 22. September 2008 schrieb Trond Myklebust:
> On Mon, 2008-09-22 at 18:05 +0200, Hans-Peter Jansen wrote:
> > For what is worth, this behavior is visible in bog standard
> > writing/reading files, (log files in my case, via the python logging
> > package). It obviously deviates from local filesystem behavior, and
> > former state of the linux nfs-client. Should we add patches to less,
> > tail, and all other instruments for watching/analysing log files (just
> > to pick the tip of the ice rock) in order to throw away runs of zeros,
> > when reading from nfs mounted files? Or should we ask their maintainers
> > to add locking code for the nfs "read files, which are written at the
> > same time" case, just to work around __some__ of the consequences of
> > this bug? Imagine, how ugly this is going to look!
> >
> > The whole issue is what I call a major regression, thus I strongly ask
> > for a reply from Trond on this matter.
> >
> > I even vote for sending a revert request for this hunk to the stable
> > team, where it is applicable, after Trond sorted it out (for 2.6.27?).
> >
> > Thanks, Aaron and Chuck for the detailed analysis - it demystified a
> > wired behavior, I observed here. When you're in a process to get real
> > work done in a fixed timeline, such things could make you mad..
>
> Revert _what_ exactly?
For your convenience, important parts inlined here:

>From Aarons message: Tue, 9 Sep 2008 12:46:44 -0700 in this thread. << EOM

Of the bisected offending commit:

commit e261f51f25b98c213e0b3d7f2109b117d714f69d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 5 00:35:41 2006 -0500

    NFS: Make nfs_updatepage() mark the page as dirty.
    
    This will ensure that we can call set_page_writeback() from within
    nfs_writepage(), which is always called with the page lock set.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


It seems to be this hunk which introduces the problem:


@@ -628,7 +667,6 @@ static struct nfs_page * nfs_update_request(struct 
nfs_open_context* ctx,
                                return ERR_PTR(error);
                        }
                        spin_unlock(&nfsi->req_lock);
-                       nfs_mark_request_dirty(new);
                        return new;
                }
                spin_unlock(&nfsi->req_lock);


If I add that function call back in... the problem disappears.  I don't
know if this just papers over the real problem though?  

EOM

This commit happened between 2.6.19 and 2.6.20, btw.

> Please assume that I've been travelling for the past 5 weeks, and have
> only a sketchy idea of what has been going on.

Ahh, I see, that explains, why you didn't responded earlier.

> My understanding was that this is a consequence of unordered writes
> causing the file to be extended while some other task is reading.
> AFAICS, this sort of behaviour has _always_ been possible. I can't see
> how reverting anything will fix it.

Hopefully, this helps you to remember the purpose of that change.

Cheers,
Pete

