From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: BUG: autofs4 + cd /net/<Netapp>/vol/vol[0-3] = portusage
	problems
Date: Wed, 19 Jan 2005 08:43:25 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130853963C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: autofs mailing list <autofs@linux.kernel.org>, nfs@lists.sourceforge.net,
        David Meleedy <david.meleedy@analog.com>
Return-path: <autofs-bounces@linux.kernel.org>
To: "Ian Kent" <raven@themaw.net>,
        "Mike Waychison" <Michael.Waychison@sun.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

ian, you, mike and i should should discuss transport multiplexing
offline.

my transport switch patches are here, if you want to review them:

  http://troy.citi.umich.edu/~cel/linux-2.6/2.6.9-a/release-notes.html


> -----Original Message-----
> From: Ian Kent [mailto:raven@themaw.net] 
> Sent: Tuesday, January 18, 2005 11:21 PM
> To: Mike Waychison
> Cc: autofs mailing list; nfs@lists.sourceforge.net; David Meleedy
> Subject: Re: [autofs] BUG: autofs4 + cd 
> /net/<Netapp>/vol/vol[0-3] = portusage problems
> 
> 
> On Tue, 18 Jan 2005, Mike Waychison wrote:
> 
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> > 
> > Ian Kent wrote:
> > > On Tue, 18 Jan 2005, Jeff Moyer wrote:
> > > 
> > > 
> > >>==> Regarding Re: [autofs] BUG: autofs4 + cd 
> > >>/net/<Netapp>/vol/vol[0-3] = port  usage problems; Ian Kent 
> > >><raven@themaw.net> adds:
> > >>
> > >>raven> On Mon, 17 Jan 2005, Jeff Moyer wrote:
> > >>
> > >>>>==> Regarding Re: [autofs] BUG: autofs4 + cd 
> > >>>>/net/<Netapp>/vol/vol[0-3] = port usage problems; 
> raven@themaw.net 
> > >>>>adds:
> > >>>>
> > >>
> > >>raven> On Fri, 14 Jan 2005, David Meleedy wrote:
> > >>
> > >>>>>>Ian, I have installed the multi-over patch into our 
> version of 
> > >>>>>>the >>
> > >>>>
> > >>>>automounter 4.1.3-67 (with updated large-program-map 
> patch) and so 
> > >>>>far
> > >>>>
> > >>>>>>everything looks great!  I am going to test our 
> machines for a 
> > >>>>>>longer period of time and make sure everything looks 
> stable, but 
> > >>>>>>so far, so good!
> > >>>>
> > >>raven> That sounds very encouraging. Great!
> > >>
> > >>>>Very encouraging indeed.  Good catch, Ian!
> > >>>>
> > >>>>
> > >>>>>>It seems to have eliminated the "BUG" message in the messages 
> > >>>>>>file,
> > >>>>
> > >>>>and >> it seems as though the automounter can unmount 
> /net/aflac 
> > >>>>which it was >> not able to do in the past during a reboot.  I 
> > >>>>suspect that this means >> it will use a lot less ports, and I 
> > >>>>might not even need the kernel patch >> (given the 
> small amount of 
> > >>>>mounts we actually use)
> > >>>>-- I am testing this >> as well.
> > >>>>
> > >>
> > >>raven> The BUG messages were placed there to identify 
> this happening 
> > >>raven> as this problem has come up in various forms several times.
> > >>
> > >>raven> In this case it appears to be caused by the order in which 
> > >>raven> the mounts are done (ie. received from auto.net). 
> Given that 
> > >>raven> current autofs implementation of multi-mounts must handle 
> > >>raven> them as a single unit, nested filesystem mounts, 
> made in the 
> > >>raven> wrong order, cause overmounting which caused the umount 
> > >>raven> problem.
> > >>
> > >>raven> Perhaps.
> > >>
> > >>raven> Depends on whether the mount program has the patch which 
> > >>raven> probes the NFS server. The port usage problem 
> still remains 
> > >>raven> and I expect it will continue to cause problems for us one 
> > >>raven> way or another. Hopefully it will be addressed in the near 
> > >>raven> future.
> > >>
> > >>>>Hmm, I wonder what probing it actually does.  I'll have 
> a look and 
> > >>>>see if we can change the probe code to use non-reserved ports.
> > >>
> > >>raven> I looked at the code in an FC2 mount and found that it did 
> > >>raven> quite a bit of probing.
> > >>
> > >>[snip]
> > >>
> > >>raven> This just means that we need to get a handle on the 
> > >>raven> objections to RPC transport multiplexing and get it done.
> > >>
> > >>I forwarded Mike's patch off to Steve Dickson.  However, with the 
> > >>caveats he listed, I'm not optimistic.
> > > 
> > > 
> > > Neither am I. The patch that Trond originally did is probably a 
> > > better
> > > starting point.
> > 
> > Which patches are we referring to by chance?  I'm guessing the xprt
> > stuff?   I don't know of Trond's patches that do the same.
> 
> Trond never finished them. He probably got too much flack about 
> scalability and request slot exhastion and gave up on it.
> 
> He reffered to them in a previous discussion on the same 
> topic and said 
> that if anyone wanted to port them to a current kernel and 
> finish them 
> they were welcome.
> 
> So I did that at the time for vanila kernels (2.4.22 amd 
> 2.6.0) but had no 
> confidence in my work as my understanding of the RPC 
> subsystem is fairly 
> poor and was worse at the time. I asked Trond to check them 
> but he clearly 
> didn't have time.
> 
> If you wish to look for youself they can be found at 
> http://www.kernel.org/pub/kernel/people/raven/nfs
> 
> The patch takes account of other kernel RPC users, lockd and portmap.
> 
> Basically it moves the transport allocation into the 
> transmit/receive FSM 
> using a get/put mechanism, requiring only that kernel RPC 
> users allocate 
> the client struct. It looks to me like this approach would 
> lend itself to 
> dynamic allocation of additional transports upon request slot 
> exhaustion.
> 
> I spent some time checking this last weekend and it looks 
> like porting 
> them to current kernels is not too hard but will be tedious.
> 
> Mind you I've transcribed these from Tronds' original patch and there 
> could be errors in that work so they will need to be sanity checked 
> anyway.
> 
> I'm keen to spend some more time on this, so perhaps between 
> this and what 
> you have already done we can get something that will make it 
> into the RPC 
> subsystem. Stranger things have happened.
> 
> > 
> > > 
> > > There's quite a bit to do meantime such as, general testing, 
> > > scalability
> > > testing, dynamically allocating a new transport if a 
> request slot can't be 
> > > allocated and so on.
> > > 
> > > There will be quite a bit more discussion on this I expect.
> > > 
> > > What is Steves responsibility here?
> > > 
> > > Ian
> > > 
> > > _______________________________________________
> > > autofs mailing list
> > > autofs@linux.kernel.org 
> > > http://linux.kernel.org/mailman/listinfo/autofs
> > 
> > 
> > - --
> > Mike Waychison
> > Sun Microsystems, Inc.
> > 1 (650) 352-5299 voice
> > 1 (416) 202-8336 voice
> > 
> > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > NOTICE:  The opinions expressed in this email are held by 
> me, and may 
> > not represent the views of Sun Microsystems, Inc. 
> > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > -----BEGIN PGP SIGNATURE-----
> > Version: GnuPG v1.2.5 (GNU/Linux)
> > Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org
> > 
> > iD8DBQFB7UgtdQs4kOxk3/MRAjaqAJwIYgp0GjlAH2X9Jl/wCs885AIRVgCfYBqI
> > 0nJ1cZt77/sebi1MjVlV7pk=
> > =n93V
> > -----END PGP SIGNATURE-----
> > 
> 
> _______________________________________________
> autofs mailing list
> autofs@linux.kernel.org 
> http://linux.kernel.org/mailman/listinfo/autof> s
> 
