Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40817 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757574Ab3GZPCZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 11:02:25 -0400
Date: Fri, 26 Jul 2013 11:02:22 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: Larry Keegan <lk@pfw.demon.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130726150222.GC30651@fieldses.org>
References: <20130725134515.67af44e2@cs3.al.itld>
 <20130725101143.6a22cb81@corrin.poochiereds.net>
 <20130725170526.6e54c7db@cs3.al.itld>
 <20130725141828.1862a1e1@tlielax.poochiereds.net>
 <20130726124101.058df8dc@cs3.al.itld>
 <20130726091225.5f299ff6@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130726091225.5f299ff6@corrin.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 26, 2013 at 09:12:25AM -0400, Jeff Layton wrote:
> On Fri, 26 Jul 2013 12:41:01 +0000
> Larry Keegan <lk@pfw.demon.co.uk> wrote:
> 
> > On Thu, 25 Jul 2013 14:18:28 -0400
> > Jeff Layton <jlayton@redhat.com> wrote:
> > > On Thu, 25 Jul 2013 17:05:26 +0000
> > > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > > 
> > > > On Thu, 25 Jul 2013 10:11:43 -0400
> > > > Jeff Layton <jlayton@redhat.com> wrote:
> > > > > On Thu, 25 Jul 2013 13:45:15 +0000
> > > > > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > > > > 
> > > > > > Dear Chaps,
> > > > > > 
> > > > > > I am experiencing some inexplicable NFS behaviour which I would
> > > > > > like to run past you.
> > > > > 
> > > > > Were these machines running older kernels before this started
> > > > > happening? What kernel did you upgrade from if so?
> > > > > 
> > > > [snip out my long rambling reply]
> > > > > What might be helpful is to do some network captures when the
> > > > > problem occurs. What we want to know is whether the ESTALE errors
> > > > > are coming from the server, or if the client is generating them.
> > > > > That'll narrow down where we need to look for problems.
> > > > 
> > > > As it was giving me gyp during typing I tried to capture some NFS
> > > > traffic. Unfortunately claws-mail started a mail box check in the
> > > > middle of this and the problem disappeared! Normally it's claws
> > > > which starts this. It'll come along again soon enough and I'll send
> > > > a trace.
> > > > 
> > > Ok, we had a number of changes to how ESTALE errors are handled over
> > > the last few releases. When you mentioned 3.10, I had assumed that you
> > > might be hitting a regression in one of those, but those went in well
> > > after the 3.4 series.
> > > 
> > > Captures are probably your best bet. My suspicion is that the server
> > > is returning these ESTALE errors occasionally, but it would be best to
> > > have you confirm that. They may also help make sense of why it's
> > > occurring...
> > > 
> > 
> > Dear Jeff,
> > 
> > I now have a good and a bad packet capture. I can run them through
> > tshark -V but if I do this, they're really long, so I'm wondering how
> > best to post them. I've posted the summaries below.
> > 
> > The set-up is as follows: I'm running a few xterms on my desktop (the
> > affected client) as well as claws-mail using the mailmbox plugin.
> > Claws keeps a cache of the mailbox in .clawsmail/tagsdb/<foldername>.
> > From time to time I blast a load of mail into these mail boxes using
> > procmail. This seems to demonstrate the problem most of the time. After
> > a few minutes everything gets back to normal.
> > 
> > The actual mail is being delivered on my file server pair directly
> > into /home/larry/Mail/<foldername>. Both file servers use automount to
> > mount the same filesystem

Wait, I'm confused: that sounds like you're mounting the same ext4
filesystem from two different machines?

--b.

> > and attempt to deliver mail into the boxes
> > simultaneously. Clearly the .lock files stop them stomping on each
> > other. This works well.
> > 
> > When it's in the mood to work, the test session on my desktop looks
> > like this:
> > 
> > # ls .claws-mail/tagsdb
> > #mailmbox  #mh
> > # _
> > 
> > When it doesn't it looks like this:
> > 
> > # ls .claws-mail/tagsdb
> > ls: cannot open directory .claws-mail/tagsdb: Stale NFS file handle
> > # _
> > 
> > I captured the packets on the network desktop. All else was quiet on
> > the network, at least as far as TCP traffic was concerned. Here are the
> > summaries:
> > 
> > # tshark -r good tcp
> >  10 1.304139000   10.1.1.139 -> 10.1.1.173   NFS 238 V4 Call ACCESS FH:0x4e5465ab, [Check: RD LU MD XT DL]
> >  11 1.304653000   10.1.1.173 -> 10.1.1.139   NFS 194 V4 Reply (Call In 10) ACCESS, [Allowed: RD LU MD XT DL]
> >  12 1.304694000   10.1.1.139 -> 10.1.1.173   TCP 66 gdoi > nfs [ACK] Seq=173 Ack=129 Win=3507 Len=0 TSval=119293240 TSecr=440910222
> >  13 1.304740000   10.1.1.139 -> 10.1.1.173   NFS 250 V4 Call LOOKUP DH:0x4e5465ab/tagsdb
> >  14 1.305225000   10.1.1.173 -> 10.1.1.139   NFS 310 V4 Reply (Call In 13) LOOKUP
> >  15 1.305283000   10.1.1.139 -> 10.1.1.173   NFS 238 V4 Call ACCESS FH:0x4e5465ab, [Check: RD LU MD XT DL]
> >  16 1.305798000   10.1.1.173 -> 10.1.1.139   NFS 194 V4 Reply (Call In 15) ACCESS, [Allowed: RD LU MD XT DL]
> >  17 1.305835000   10.1.1.139 -> 10.1.1.173   NFS 250 V4 Call LOOKUP DH:0x4e5465ab/tagsdb
> >  18 1.306330000   10.1.1.173 -> 10.1.1.139   NFS 310 V4 Reply (Call In 17) LOOKUP
> >  19 1.306373000   10.1.1.139 -> 10.1.1.173   NFS 230 V4 Call GETATTR FH:0x445c531a
> >  20 1.306864000   10.1.1.173 -> 10.1.1.139   NFS 262 V4 Reply (Call In 19) GETATTR
> >  21 1.346003000   10.1.1.139 -> 10.1.1.173   TCP 66 gdoi > nfs [ACK]  Seq=877 Ack=941 Win=3507 Len=0 TSval=119293282 TSecr=440910225
> > # tshark -r bad tcp
> >  14 2.078769000   10.1.1.139 -> 10.1.1.173   NFS 238 V4 Call ACCESS FH:0x76aee435, [Check: RD LU MD XT DL]
> >  15 2.079266000   10.1.1.173 -> 10.1.1.139   NFS 194 V4 Reply (Call In 14) ACCESS, [Allowed: RD LU MD XT DL]
> >  16 2.079296000   10.1.1.139 -> 10.1.1.173   TCP 66 gdoi > nfs [ACK] Seq=173 Ack=129 Win=3507 Len=0 TSval=180576023 TSecr=502193004
> >  17 2.079338000   10.1.1.139 -> 10.1.1.173   NFS 238 V4 Call ACCESS FH:0x4e5465ab, [Check: RD LU MD XT DL]
> >  18 2.079797000   10.1.1.173 -> 10.1.1.139   NFS 194 V4 Reply (Call In 17) ACCESS, [Allowed: RD LU MD XT DL]
> >  19 2.079834000   10.1.1.139 -> 10.1.1.173   NFS 230 V4 Call GETATTR FH:0xb12cdc45
> >  20 2.080331000   10.1.1.173 -> 10.1.1.139   NFS 262 V4 Reply (Call In 19) GETATTR
> >  21 2.080410000   10.1.1.139 -> 10.1.1.173   NFS 250 V4 Call LOOKUP DH:0x4e5465ab/tagsdb
> >  22 2.080903000   10.1.1.173 -> 10.1.1.139   NFS 310 V4 Reply (Call In 21) LOOKUP
> >  23 2.080982000   10.1.1.139 -> 10.1.1.173   NFS 226 V4 Call GETATTR FH:0xb12cdc45
> >  24 2.081477000   10.1.1.173 -> 10.1.1.139   NFS 162 V4 Reply (Call In 23) GETATTR
> >  25 2.081509000   10.1.1.139 -> 10.1.1.173   NFS 230 V4 Call GETATTR FH:0xb12cdc45
> >  26 2.082010000   10.1.1.173 -> 10.1.1.139   NFS 178 V4 Reply (Call In 25) GETATTR
> >  27 2.082040000   10.1.1.139 -> 10.1.1.173   NFS 226 V4 Call GETATTR FH:0xb12cdc45
> >  28 2.082542000   10.1.1.173 -> 10.1.1.139   NFS 142 V4 Reply (Call In 27) GETATTR
> >  29 2.089525000   10.1.1.139 -> 10.1.1.173   NFS 226 V4 Call GETATTR FH:0xb12cdc45
> >  30 2.089996000   10.1.1.173 -> 10.1.1.139   NFS 162 V4 Reply (Call In 29) GETATTR
> >  31 2.090028000   10.1.1.139 -> 10.1.1.173   NFS 230 V4 Call GETATTR FH:0xb12cdc45
> >  32 2.090529000   10.1.1.173 -> 10.1.1.139   NFS 262 V4 Reply (Call In 31) GETATTR
> >  33 2.090577000   10.1.1.139 -> 10.1.1.173   NFS 230 V4 Call GETATTR FH:0x4e5465ab
> >  34 2.091061000   10.1.1.173 -> 10.1.1.139   NFS 262 V4 Reply (Call In 33) GETATTR
> >  35 2.091110000   10.1.1.139 -> 10.1.1.173   NFS 250 V4 Call LOOKUP DH:0x4e5465ab/tagsdb
> >  36 2.091593000   10.1.1.173 -> 10.1.1.139   NFS 310 V4 Reply (Call In 35) LOOKUP
> >  37 2.091657000   10.1.1.139 -> 10.1.1.173   NFS 226 V4 Call GETATTR FH:0xb12cdc45
> >  38 2.092126000   10.1.1.173 -> 10.1.1.139   NFS 162 V4 Reply (Call In 37) GETATTR
> >  39 2.092157000   10.1.1.139 -> 10.1.1.173   NFS 230 V4 Call GETATTR FH:0xb12cdc45
> >  40 2.092658000   10.1.1.173 -> 10.1.1.139   NFS 178 V4 Reply (Call In 39) GETATTR
> >  41 2.092684000   10.1.1.139 -> 10.1.1.173   NFS 226 V4 Call GETATTR FH:0xb12cdc45
> >  42 2.093150000   10.1.1.173 -> 10.1.1.139   NFS 142 V4 Reply (Call In 41) GETATTR
> >  43 2.100520000   10.1.1.139 -> 10.1.1.173   NFS 226 V4 Call GETATTR FH:0xb12cdc45
> >  44 2.101014000   10.1.1.173 -> 10.1.1.139   NFS 162 V4 Reply (Call In 43) GETATTR
> >  45 2.101040000   10.1.1.139 -> 10.1.1.173   NFS 230 V4 Call GETATTR FH:0xb12cdc45
> >  46 2.101547000   10.1.1.173 -> 10.1.1.139   NFS 262 V4 Reply (Call In 45) GETATTR
> >  47 2.141500000   10.1.1.139 -> 10.1.1.173   TCP 66 gdoi > nfs [ACK] Seq=2657 Ack=2289 Win=3507 Len=0 TSval=180576086 TSecr=502193026
> > # _
> > 
> > The first thing that strikes me is the bad trace is much longer. This
> > strikes me as reasonable because as well as the ESTALE problem I've
> > noticed that the whole system seems sluggish. claws-mail is
> > particularly so because it keeps saving my typing into a drafts
> > mailbox, and because claws doesn't really understand traditional
> > mboxes, it spends an inordinate amount of time locking and unlocking
> > the boxes for each message in them. Claws also spews tracebacks
> > frequently and it crashes from time to time, something it never did
> > before the ESTALE problem occurred.
> > 
> > Yours,
> > 
> > Larry
> 
> I'm afraid I can't tell much from the above output. I don't see any
> ESTALE errors there, but you can get similar issues if (for instance)
> certain attributes of a file change. You mentioned that this is a DRBD
> cluster, are you "floating" IP addresses between cluster nodes here? If
> so, do your problems occur around the times that that's happening?
> 
> Also, what sort of filesystem is being exported here?
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
