Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:34125 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbbHEPLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 11:11:36 -0400
Received: by ykax123 with SMTP id x123so37970655yka.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 08:11:36 -0700 (PDT)
Date: Wed, 5 Aug 2015 11:11:32 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Andrew W Elble <aweits@rit.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
Message-ID: <20150805111132.01a14348@tlielax.poochiereds.net>
In-Reply-To: <m2bnemg64d.fsf@discipline.rit.edu>
References: <m23809zl8z.fsf@discipline.rit.edu>
	<m2zj2hwk4e.fsf@discipline.rit.edu>
	<20150728090206.1331e476@tlielax.poochiereds.net>
	<m2wpxktjfc.fsf@discipline.rit.edu>
	<20150728114933.6f917374@tlielax.poochiereds.net>
	<20150728210434.GC9349@fieldses.org>
	<m24mknq9ga.fsf@discipline.rit.edu>
	<m28u9yoi6z.fsf@discipline.rit.edu>
	<m2bnetnbme.fsf@discipline.rit.edu>
	<20150730085723.0ab8e76c@tlielax.poochiereds.net>
	<m2bnemg64d.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 04 Aug 2015 16:18:10 -0400
Andrew W Elble <aweits@rit.edu> wrote:

> 
> > In any case, I think this explains where the "no readable file" warning
> > is coming from, but I'm not sure yet about the mem corruption...
> 
> Forgive my shorthand, but I think this is what we're seeing:
> 
> open2              close
>  create 1 (idr)
>  init 2 (hashed)
> 

I'm not sure I'm following your shorthand correctly, but, I'm guessing
the above is that you're creating a stateid and then calling
init_open_stateid on it to hash it?

If you can flesh out the description of the race, it might be more
clear.

>                    close preprocess_seqid 3 (local ref in nfsd4_close)
> 		   close_open_stateid 2 -> unhashed (unhashed)
> 

Ok, so here we have the client sending a simultaneous close for the
same stateid? How did it get it in the first place? We won't have sent
the reply yet to the OPEN that this CLOSE is racing with.

Unless...the initial task that created the stateid got _really_
stalled, and another OPEN raced in, found that stateid and was able to
reply quickly. Then the client could send a CLOSE for that second OPEN
before the first opener ever finished.

In any case, we really do need to make subsequent openers of a nfs4_file
wait until it's fully constructed before using it.

>  release_open_stateid 1 -> list_del corruption (because unhashed already
>                         -> should still be refcount 2?)
> 

...regardless, I do agree that the release_open_stateid call here is
probably making some assumptions that it shouldn't, and that is probably
where the list corruption is coming in. 

If you had multiple racing OPENs then one could find the stateid that
was previously hashed. A simple fix might be to just use list_del_init
calls in unhash_ol_stateid. That should make any second list_del's a
no-op.

Whether that's sufficient to fix the mem corruption, I'm not sure...

>                    nfs4_put_stid 0 -> destroyed
> 
>  nfs4_put_stid 0 -> use after free
> 
> This also explains the '6a' as the first byte, as the final
> nfs4_put_stid will decrement sc_count first. There are other permutations.
> 
> Also, the return-with-status from nfs_get_vfs_file() appears to be break_lease()
> (much further down) returning -EWOULDBLOCK (in both cases, memory
> corruption and the simple warning case)
> 
> Thanks,
> 
> Andy


-- 
Jeff Layton <jlayton@poochiereds.net>
