Return-Path: <jlayton@redhat.com>
Message-ID: <1508264368.4747.17.camel@redhat.com>
Subject: Re: [PATCH] nfsd4: Prevent the reuse of a closed stateid
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Date: Tue, 17 Oct 2017 14:19:28 -0400
In-Reply-To: <F5CCE778-0A1E-4818-8D9B-7F45FC3E7F4B@redhat.com>
References: 
	<2087b4cab6c695a7df01c1135f1773c9b762f0b0.1508248427.git.bcodding@redhat.com>
	 <1508258356.4747.6.camel@redhat.com>
	 <F5CCE778-0A1E-4818-8D9B-7F45FC3E7F4B@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-10-17 at 13:46 -0400, Benjamin Coddington wrote:
> On 17 Oct 2017, at 12:39, Jeff Layton wrote:
> 
> > On Tue, 2017-10-17 at 09:55 -0400, Benjamin Coddington wrote:
> > > While running generic/089 on NFSv4.1, the following on-the-wire 
> > > exchange
> > > occurs:
> > > 
> > > Client                  Server
> > > ----------              ----------
> > > OPEN (owner A)  ->
> > >                     <-  OPEN response: state A1
> > > CLOSE (state A1)->
> > > OPEN (owner A)  ->
> > >                     <-  CLOSE response: state A2
> > >                     <-  OPEN response: state A3
> > > LOCK (state A3) ->
> > >                     <-  LOCK response: NFS4_BAD_STATEID
> > > 
> > > The server should not be returning state A3 in response to the second 
> > > OPEN
> > > after processing the CLOSE and sending back state A2.  The problem is 
> > > that
> > > nfsd4_process_open2() is able to find an existing open state just 
> > > after
> > > nfsd4_close() has incremented the state's sequence number but before
> > > calling unhash_ol_stateid().
> > > 
> > > Fix this by using the state's sc_type field to identify closed state, 
> > > and
> > > protect the update of that field with st_mutex.  
> > > nfsd4_find_existing_open()
> > > will return with the st_mutex held, so that the state will not 
> > > transition
> > > between being looked up and then updated in nfsd4_process_open2().
> > > 
> > > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > > ---
> > >  fs/nfsd/nfs4state.c | 29 +++++++++++++++++++----------
> > >  1 file changed, 19 insertions(+), 10 deletions(-)
> > > 
> > 
> > The problem is real, but I'm not thrilled with the fix. It seems more
> > lock thrashy...
> 
> Really?  I don't think I increased any call counts to spinlocks or mutex
> locks.  The locking overhead should be equivalent.
> 

init_open_stateid will now end up taking fi_lock twice. Also we now have
to take the st_mutex in nfsd4_find_existing_open, just to check sc_type.
Neither of those are probably unreasonable, it's just messier than I'd
like.

> > Could we instead fix this by just unhashing the stateid earlier, 
> > before
> > the nfs4_inc_and_copy_stateid call?
> 
> I think I tried this - and if I remember correctly, the problem is that 
> you
> can't hold st_mutux while taking the cl_lock (or maybe it was the 
> fi_lock?).
> I tried several simpler ways, and they resulted in deadlocks.
> 
> That was a couple of weeks ago, so I apologize if my memory is fuzzy.  I
> should have sent this patch off to the list then.  If you need me to to
> verify that, I can - but maybe someone more familiar with the locking 
> here
> can save me that time.
> 
> Ben


There should be no problem taking the cl_lock while holding st_mutex.
It's never safe to do the reverse though. I'd just do the unhash before 
nfs4_inc_and_copy_stateid, and then save the rest of the stuff in
nfsd4_close_open_stateid for after the st_mutex has been dropped.

I think what I'm suggesting is possible. You may need to unroll
nfsd4_close_open_stateid to make it work though.

-- 
Jeff Layton <jlayton@redhat.com>
